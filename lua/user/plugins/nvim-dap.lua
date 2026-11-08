-- Cross-platform debug adapter setup.
--
-- Adapters:
--   codelldb        (LLVM-backed lldb wrapper, supports c/cpp/rust)
--   netcoredbg      (c#, expected on PATH / a fixed path on Windows)
--   js-debug-adapter (vscode-js-debug, for node/javascript/typescript)
--
-- The mason-managed ones install via `:MasonInstall codelldb js-debug-adapter`
-- and land under nvim-data/mason/packages/<pkg>/.
--
-- macOS extras (keymaps + xcodebuild integration) live in xcodebuild.lua so
-- this file stays portable.
return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"jay-babu/mason-nvim-dap.nvim",
		"williamboman/mason.nvim",
		-- dap-ui configures itself (see nvim-dap-ui.lua) but has no load
		-- trigger of its own, so without this it never loaded and the
		-- auto-open listeners never got registered.
		"rcarriga/nvim-dap-ui",
	},
	config = function()
		local dap = require("dap")

		-- Make sure mason actually installs the adapters. mason-nvim-dap also
		-- registers DAP-side adapter wiring for packages it knows about.
		require("mason-nvim-dap").setup({
			ensure_installed = { "codelldb", "js-debug-adapter" },
			automatic_installation = true,
			-- We define our own configs below; let mason-nvim-dap only do
			-- adapter setup (the `default_setup` it ships with has been known
			-- to clobber custom configurations).
			handlers = {},
		})

		-- Resolve the codelldb binary mason just installed. We do this lazily
		-- (inside the adapter command) so that the first nvim launch -- before
		-- mason has finished downloading -- doesn't error out at config time.
		local function codelldb_command()
			local mason_root = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter"
			local exe = vim.fn.has("win32") == 1 and "codelldb.exe" or "codelldb"
			return mason_root .. "/" .. exe
		end

		-- vscode-js-debug ships as a node program rather than a standalone
		-- binary, so we run it with whatever `node` is on PATH. It listens on
		-- the port nvim-dap picks and speaks DAP over TCP.
		local function js_debug_server()
			return vim.fn.stdpath("data")
				.. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
		end

		dap.adapters.coreclr = {
			type = 'executable',
			-- On Windows the binary must include the .exe extension; libuv
			-- (used to spawn the adapter) does not resolve it automatically.
			command = vim.fn.has("win32") == 1
				and 'C:/Program Files/misc/netcoredbg.exe'
				or 'netcoredbg',
			args = {'--interpreter=vscode'}
		}

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = codelldb_command(),
				args = { "--port", "${port}" },
				-- codelldb on Windows needs detached=false, otherwise it
				-- briefly flashes a console window and inherits stdio in a way
				-- that breaks debug sessions.
				detached = vim.fn.has("win32") == 0,
			},
		}

		-- js-debug exposes several debug "types" from one server; `pwa-node` is
		-- the node one. The adapter is registered under each type name we use
		-- because nvim-dap looks the adapter up by the config's `type`.
		dap.adapters["pwa-node"] = {
			type = "server",
			host = "127.0.0.1",
			port = "${port}",
			executable = {
				command = "node",
				-- The host argument is not optional in practice: given only a
				-- port, dapDebugServer binds ::1, and nvim-dap connects to
				-- 127.0.0.1 -- so every session dies with ECONNREFUSED (and the
				-- error message unhelpfully reports the literal "${port}").
				args = { js_debug_server(), "${port}", "127.0.0.1" },
			},
		}

		-- C / C++ / Rust launch configurations. "Launch file" prompts for the
		-- executable; "Launch file with args" also prompts for argv. Args
		-- accept whitespace-split tokens, or `@path/to/file` to pass a single
		-- argv entry containing that file's full contents (handy for JSON or
		-- query payloads). Ported from the old config's dap-cpp.lua.
		local last_program = nil
		local last_args = ""

		local function read_file_as_arg(path)
			local fd, err = io.open(path, "rb")
			if not fd then
				vim.notify("dap: could not read " .. path .. ": " .. tostring(err), vim.log.levels.ERROR)
				return {}
			end
			local contents = fd:read("*a") or ""
			fd:close()
			contents = contents:gsub("\r?\n$", "")
			return { contents }
		end

		-- Shell-ish argv splitting. There is no shell between this prompt and
		-- the debuggee, so a plain whitespace split turns `foo bar` into two
		-- argv entries -- surprising when the program expects one. Honor
		-- single and double quotes for grouping. No escapes, no variable or
		-- glob expansion: use the @file form for anything fancier.
		local function split_args(raw)
			local args, cur, quote = {}, nil, nil
			for ch in raw:gmatch(".") do
				if quote then
					if ch == quote then
						quote = nil
					else
						cur = (cur or "") .. ch
					end
				elseif ch == "'" or ch == '"' then
					quote = ch
					cur = cur or ""
				elseif ch:match("%s") then
					if cur then
						table.insert(args, cur)
						cur = nil
					end
				else
					cur = (cur or "") .. ch
				end
			end
			if cur then
				table.insert(args, cur)
			end
			if quote then
				vim.notify("dap: unterminated " .. quote .. " in args", vim.log.levels.WARN)
			end
			return args
		end

		local launch = {
			type = "codelldb",
			request = "launch",
			name = "Launch file",
			program = function()
				local default = last_program or (vim.fn.getcwd() .. "/")
				local p = vim.fn.input("Path to executable: ", default, "file")
				last_program = p
				return p
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			-- Let the adapter launch the process itself instead of handing off
			-- to codelldb-launch in an integrated terminal. The handoff races:
			-- if the adapter closes the socket before sending the launch
			-- payload, the launcher dies with
			--   Error("EOF while parsing a value", line: 1, column: 0)
			-- Output still arrives as DAP output events in the dapui console.
			-- Tradeoff: no interactive stdin.
			terminal = "console",
		}

		local launch_with_args = vim.tbl_extend("force", launch, {
			name = "Launch file with args",
			args = function()
				local raw = vim.fn.input("Args (or @file): ", last_args, "file")
				last_args = raw
				if raw == "" then
					return {}
				end
				if raw:sub(1, 1) == "@" then
					return read_file_as_arg(raw:sub(2))
				end
				return split_args(raw)
			end,
		})

		for _, lang in ipairs({ "c", "cpp", "rust" }) do
			dap.configurations[lang] = { launch, launch_with_args }
		end

		-- JavaScript / TypeScript. Deliberately ONE config: nvim-dap only skips
		-- the "select a configuration" prompt when a filetype has exactly one,
		-- so <leader>dc on a js buffer starts debugging with zero questions.
		-- Attach-to-process is intentionally absent -- `dap.utils.pick_process`
		-- is unfiltered and makes you scroll the whole process table.
		local js_configs = {
			{
				type = "pwa-node",
				request = "launch",
				name = "Launch current file",
				program = "${file}",
				cwd = "${workspaceFolder}",
				sourceMaps = true,
				-- Keep node's own internals and dependencies out of the stack
				-- trace and out of step-into, otherwise stepping lands in
				-- module loader shims.
				skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
				-- Run the debuggee in a terminal buffer so stdout/stdin work
				-- normally; the "console" alternative swallows input entirely.
				console = "integratedTerminal",
			},
		}

		for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
			dap.configurations[lang] = js_configs
		end

		-- Find the most likely application DLL to launch: locate each .csproj
		-- under the cwd, derive its assembly name, and look for the matching
		-- built dll under bin/Debug/net*/. Returns the newest match so a
		-- freshly-built target framework wins.
		local function find_dotnet_dll()
			local cwd = vim.fn.getcwd()
			local csprojs = vim.fn.glob(cwd .. "/**/*.csproj", true, true)
			for _, proj in ipairs(csprojs) do
				local name = vim.fn.fnamemodify(proj, ":t:r")
				local dir = vim.fn.fnamemodify(proj, ":h")
				local dlls = vim.fn.glob(dir .. "/bin/Debug/net*/" .. name .. ".dll", true, true)
				if #dlls > 0 then
					return dlls[#dlls]
				end
			end
			return cwd .. "/"
		end

		local cs_last_dll = nil

		dap.configurations.cs = {
			{
				type = "coreclr",
				name = "launch - netcoredbg",
				request = "launch",
				program = function()
					local p = vim.fn.input("Path to dll: ", cs_last_dll or find_dotnet_dll(), "file")
					cs_last_dll = p
					return p
				end,
				-- Run from the dll's output directory so appsettings.json and
				-- other content-root relative files resolve correctly.
				cwd = function()
					return vim.fn.fnamemodify(cs_last_dll or find_dotnet_dll(), ":h")
				end,
				stopAtEntry = false,
				-- Run the app in an integrated terminal buffer so Console
				-- output (launch banner, Console.WriteLine, request logs) is
				-- visible, instead of being swallowed by DAP output events.
				console = "integratedTerminal",
			},
		}

		-- Generic debug keymaps. These are intentionally distinct from the
		-- xcodebuild bindings (which use <leader>x* for build/test). Use
		-- <leader>b for breakpoints because <leader>db conflicted with too
		-- many other "debug start" muscle memory.
		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { desc = desc })
		end
		map("<leader>b", function() dap.toggle_breakpoint() end, "Toggle Breakpoint")
		map("<leader>B", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, "Conditional Breakpoint")
		map("<leader>dc", function() dap.continue() end, "Debug: Continue / Start")
		map("<leader>dn", function() dap.step_over() end, "Debug: Step Over")
		map("<leader>di", function() dap.step_into() end, "Debug: Step Into")
		map("<leader>do", function() dap.step_out() end, "Debug: Step Out")
		map("<leader>dx", function() dap.terminate() end, "Debug: Terminate")
		map("<leader>dr", function() dap.repl.toggle() end, "Debug: Toggle REPL")
		map("<leader>dl", function() dap.run_last() end, "Debug: Run Last")
	end,
}
