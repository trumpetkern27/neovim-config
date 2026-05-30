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
