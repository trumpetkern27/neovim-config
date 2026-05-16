return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",        -- lua
					"pyright",       -- python
					"clangd",        -- c and c++
					"csharp_ls",     -- c#
					"rust_analyzer", -- rust
					"ts_ls",         -- typescript/javascript
					"asm_lsp",       -- x86/arm assembly
				},
				automatic_installation = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local servers = {
				"lua_ls",
				"pyright",
				"clangd",
				"csharp_ls",
				"rust_analyzer",
				"ts_ls",
				"asm_lsp",
			}
			for _, server in ipairs(servers) do
				vim.lsp.config(server, {
					capabilities = capabilities,
				})
			end
		end,
	},
}
