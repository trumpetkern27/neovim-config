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
					"lua_ls", -- lua
					"pyright", -- python
					"clangd", -- c and c++
					"csharp_ls", -- c#
					"rust_analyzer", -- rust
					"ts_ls", -- typescript/javascript
					"asm_lsp", -- x86/arm assembly
				},
				automatic_installation = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local lspconfig = require("lspconfig")
			local util = require("lspconfig.util")
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local capabilities = cmp_nvim_lsp.default_capabilities()
			local opts = { noremap = true, silent = true }
			local on_attach = function(_, bufnr)
				opts.buffer = bufnr
				opts.desc = "Show line diagnostics"
				vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Show documentation for what is under cursor"
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			end
			local servers = {
				"lua_ls",
				"pyright",
				"clangd",
				"csharp_ls",
				"rust_analyzer",
				"ts_ls",
				"asm_lsp",
				"sourcekit_lsp",
			}
			for _, server in ipairs(servers) do
				vim.lsp.config(server, {
					capabilities = capabilities,
					on_attach = on_attach,
				})
				vim.lsp.enable(server)
			end

			--swift
			vim.lsp.config("sourcekit_lsp", {
				cmd = { "xcrun", "sourcekit-lsp" },
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable("sourcekit")
		end,
	},
}
