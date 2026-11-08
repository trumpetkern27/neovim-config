return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				-- Crashdummyy hosts the `roslyn` package (the official Microsoft
				-- C# language server). It isn't in mason core, so without this
				-- registry `:MasonInstall roslyn` would fail and roslyn.nvim
				-- would have nothing to start.
				registries = {
					"github:mason-org/mason-registry",
					"github:Crashdummyy/mason-registry",
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls", -- lua
					"pyright", -- python
					"clangd", -- c and c++
					"rust_analyzer", -- rust
					"ts_ls", -- typescript/javascript
					"asm_lsp", -- x86/arm assembly (mason `cargo install`s this; ~/.cargo/bin must be on PATH)
				},
				-- Mason 2.x will, by default, call `vim.lsp.enable()` on every
				-- installed mason package that has an lspconfig mapping --
				-- including stuff you uninstalled from your config but didn't
				-- yet uninstall from mason. That's how csharp_ls and omnisharp
				-- kept attaching to every .cs buffer and fighting roslyn.
				-- We enable servers explicitly in the nvim-lspconfig block
				-- below instead, so this stays off.
				automatic_enable = false,
				-- See note above about lockfile races.
				automatic_installation = false,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			-- All keymaps live in a single LspAttach autocmd. This way they
			-- get installed for ANY client that attaches -- roslyn (started
			-- by roslyn.nvim), clangd, lua_ls, anything. Previous code used a
			-- per-server on_attach, which silently skipped roslyn because we
			-- never enabled it through this loop. Net effect: `gd` was unmapped
			-- on .cs buffers.
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
				callback = function(ev)
					local bufnr = ev.buf
					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, {
							buffer = bufnr,
							noremap = true,
							silent = true,
							desc = desc,
						})
					end

					-- Navigation. Nvim 0.11+ ships grr/gri/grn/gra/gO defaults
					-- but deliberately leaves `gd` unmapped (vanilla `gd` is a
					-- local-buffer regex search, not LSP).
					map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
					map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
					map("n", "gy", vim.lsp.buf.type_definition, "LSP: Go to type definition")
					map("n", "gi", vim.lsp.buf.implementation, "LSP: Go to implementation")
					map("n", "gr", vim.lsp.buf.references, "LSP: References")

					map("n", "K", vim.lsp.buf.hover, "LSP: Hover docs")
					map({ "i", "s" }, "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature help")
					map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: Code action")

					map("n", "<leader>d", vim.diagnostic.open_float, "Diagnostics: Line float")
					map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Diagnostics: Prev")
					map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Diagnostics: Next")
				end,
			})

			-- Plain .js files with no tsconfig/jsconfig get an "inferred project",
			-- and tsserver only reports SYNTAX errors there -- semantic ones
			-- (undeclared variable, bad argument type) are silently dropped.
			-- That's why `for (num in arr)` linted clean but threw
			-- "ReferenceError: num is not defined" under node.
			-- implicitProjectConfiguration.checkJs defaults to false; flipping it
			-- here turns on semantic diagnostics for every .js buffer without
			-- needing a jsconfig.json in each project.
			-- Caveat: checkJs also surfaces the implicit-any family ("Parameter
			-- 'x' implicitly has an 'any' type"). noImplicitAny is NOT reachable
			-- from settings -- the server only forwards checkJs,
			-- experimentalDecorators, strict, strictNullChecks,
			-- strictFunctionTypes, module and target into the inferred project.
			-- It's also all-or-nothing per project, so a tsconfig couldn't split
			-- js from ts either. Hence the client-side filter below: drop these
			-- codes in .js buffers (where you can't annotate), keep every one of
			-- them in .ts buffers (where you can).
			local implicit_any_codes = {
				[7005] = true, -- Variable implicitly has an 'any' type
				[7006] = true, -- Parameter implicitly has an 'any' type
				[7008] = true, -- Member implicitly has an 'any' type
				[7009] = true, -- 'new' expression implicitly has an 'any' type
				[7010] = true, -- Function lacking return annotation
				[7011] = true, -- Function expression lacking return annotation
				[7015] = true, -- Element implicitly 'any' (non-numeric index)
				[7016] = true, -- Untyped module import
				[7017] = true, -- Element implicitly 'any' (no index signature)
				[7018] = true, -- Object literal property implicitly 'any'
				[7019] = true, -- Rest parameter implicitly 'any[]'
				[7022] = true, -- Self-referential initializer
				[7023] = true, -- Function implicitly has return type 'any'
				[7024] = true, -- Function implicitly has return type 'any'
				[7026] = true, -- JSX element implicitly has type 'any'
				[7031] = true, -- Binding element implicitly has an 'any' type
				[7034] = true, -- Variable implicitly 'any' in some locations
				[7053] = true, -- Element implicitly 'any' (string index)
			}

			-- ts_ls advertises no diagnosticProvider, so diagnostics arrive by
			-- push (textDocument/publishDiagnostics), not pull. Hooking the pull
			-- handler here would silently do nothing.
			local function strip_implicit_any(err, result, ctx)
				if result and type(result.uri) == "string" and result.diagnostics then
					-- Match on the URI rather than the buffer: the buffer may not
					-- be loaded yet when diagnostics land for an imported file.
					if result.uri:match("%.[cm]?jsx?$") then
						local kept = {}
						for _, d in ipairs(result.diagnostics) do
							if not implicit_any_codes[tonumber(d.code)] then
								kept[#kept + 1] = d
							end
						end
						result.diagnostics = kept
					end
				end
				return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx)
			end

			vim.lsp.config("ts_ls", {
				settings = {
					implicitProjectConfiguration = {
						checkJs = true,
					},
				},
				handlers = {
					["textDocument/publishDiagnostics"] = strip_implicit_any,
				},
			})

			-- Servers we want attached. Roslyn (C#) intentionally not here --
			-- roslyn.nvim registers and enables it itself, and its cmd is
			-- overridden in plugins/roslyn.lua to dodge the Windows .cmd
			-- shim arg-mangling issue.
			local servers = {
				"lua_ls",
				"pyright",
				"clangd",
				"rust_analyzer",
				"ts_ls",
				"asm_lsp",
			}
			for _, server in ipairs(servers) do
				vim.lsp.enable(server)
			end

			-- clangd platform toggle.
			--
			-- clangd runs the preprocessor ONCE and follows a single branch,
			-- chosen by the target triple. On Windows `_WIN32` is defined, so
			-- `#ifndef _WIN32` POSIX branches are treated as dead code and never
			-- diagnosed. There is no "check both platforms" mode -- so to get
			-- real errors inside a POSIX branch we flip clangd's whole view to
			-- a Linux target (headers come from the WSL Arch sysroot). Doing so
			-- darkens the Windows branch, which is why this is a toggle rather
			-- than permanent.
			--
			-- Mechanism: we keep two sibling templates in the project root --
			-- compile_flags.win.txt and compile_flags.posix.txt -- and copy the
			-- chosen one over the live compile_flags.txt, then restart clangd.
			local function clangd_switch(mode)
				local src = "compile_flags." .. mode .. ".txt"
				local base = vim.fn.expand("%:p:h")
				if base == "" then
					base = vim.fn.getcwd()
				end
				local found = vim.fs.find(src, { upward = true, path = base })[1]
				if not found then
					vim.notify("clangd toggle: " .. src .. " not found above this buffer", vim.log.levels.ERROR)
					return
				end
				local root = vim.fs.dirname(found)
				local dst = root .. "/compile_flags.txt"

				local fin = assert(io.open(found, "rb"))
				local data = fin:read("*a")
				fin:close()
				local fout = assert(io.open(dst, "wb"))
				fout:write(data)
				fout:close()

				for _, client in ipairs(vim.lsp.get_clients({ name = "clangd" })) do
					client:stop()
				end
				-- Give the old clangd a moment to exit, then re-edit the buffer
				-- so vim.lsp.enable("clangd") re-attaches a fresh process that
				-- reads the swapped flags. If it doesn't reattach, just `:edit`.
				vim.defer_fn(function()
					vim.cmd("edit")
					vim.notify("clangd -> " .. mode .. "  (" .. dst .. ")")
				end, 500)
			end

			vim.api.nvim_create_user_command("ClangdPosix", function()
				clangd_switch("posix")
			end, { desc = "clangd: Linux/POSIX view via WSL sysroot (checks #ifndef _WIN32)" })
			vim.api.nvim_create_user_command("ClangdWindows", function()
				clangd_switch("win")
			end, { desc = "clangd: back to the Windows build view" })

			-- Swift / Apple platforms only. xcrun doesn't exist off macOS.
			if vim.fn.has("mac") == 1 then
				vim.lsp.config("sourcekit", {
					cmd = { "xcrun", "sourcekit-lsp" },
				})
				vim.lsp.enable("sourcekit")
			end
		end,
	},
}
