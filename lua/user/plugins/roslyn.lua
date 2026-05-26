-- C# via the official Microsoft Roslyn language server (the same one VS Code's
-- C# Dev Kit uses). seblyng/roslyn.nvim auto-discovers the mason package and
-- handles project/solution loading.
--
-- Two non-obvious things this file does:
--
-- 1. cmd override.
--    Mason puts a `roslyn.cmd` shim in nvim-data/mason/bin. Neovim spawns
--    .cmd files via libuv -> cmd.exe /c, and arg forwarding through `%*`
--    mangles roslyn's flags. The server falls into its no-args branch and
--    exits; nvim surfaces it as `INVALID_SERVER_MESSAGE: Content-Length
--    not found in header`. Calling `dotnet` directly with the DLL hands
--    libuv a flat argv that reaches CreateProcess intact.
--
-- 2. LspAttach -> vim.lsp.diagnostic._enable(buf).
--    nvim 0.12 bug: the on-attach code at lsp.lua:865 calls _enable only
--    if client:supports_method('textDocument/diagnostic') is already true
--    at attach time. Roslyn registers its diagnostic provider dynamically
--    *after* attach via client/registerCapability, so at attach time
--    supports_method returns false and _enable never runs. handlers.lua
--    fires a one-time _refresh when registration arrives but never calls
--    _enable, so the LspNotify autocmd that pulls on every didChange is
--    never wired up. Result: the first buffer Roslyn attaches to in a
--    session has stale diagnostics until you close+reopen.
--
--    _enable is safe to call before the server registers the provider --
--    it just initialises bufstate and the LspNotify autocmd. Once
--    Roslyn registers diagnostic support, the next edit triggers a real
--    pull through that autocmd.
return {
	"seblyng/roslyn.nvim",
	ft = { "cs", "razor", "cshtml" },
	dependencies = { "neovim/nvim-lspconfig" },
	---@module "roslyn.config"
	---@type RoslynNvimConfig
	opts = {
		broad_search = true,
	},
	init = function()
		local mason = vim.fn.stdpath("data") .. "/mason/packages/roslyn"
		local dll = mason .. "/libexec/Microsoft.CodeAnalysis.LanguageServer.dll"
		if (vim.uv or vim.loop).fs_stat(dll) then
			vim.lsp.config("roslyn", {
				cmd = {
					"dotnet",
					dll,
					"--logLevel=Information",
					"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
					"--stdio",
				},
				-- Tell Roslyn to background-analyze the whole solution, not
				-- just files you have open. Otherwise dependent-file
				-- diagnostics go stale until something pokes them.
				settings = {
					["csharp|background_analysis"] = {
						dotnet_analyzer_diagnostics_scope = "fullSolution",
						dotnet_compiler_diagnostics_scope = "fullSolution",
					},
				},
			})
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("user_roslyn_diag_enable", { clear = true }),
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client or client.name ~= "roslyn" then
					return
				end
				pcall(vim.lsp.diagnostic._enable, args.buf)
			end,
		})
	end,
}
