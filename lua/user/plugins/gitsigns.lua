return {
	"lewis6991/gitsigns.nvim",
	config = function()
		vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#50fa7b" })
		vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#00ffff" })
		vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#ff3535" })
		require("gitsigns").setup({
			signs = {
				add          = { text = '┃', hl = "GitSignsAdd" },
				change       = { text = '┃', hl = "GitSignsChange" },
				delete       = { text = '_', hl = "GitSignsDelete" },
				topdelete    = { text = '‾', hl = "GitSignsDelete" },
				changedelete = { text = '~', hl = "GitSignsChange" },
				untracked    = { text = '┆', hl = "GitSignsAdd" },
			},
			signs_staged = {
				add          = { text = '┃', hl = "GitSignsAdd" },
				change       = { text = '┃', hl = "GitSignsChange" },
				delete       = { text = '_', hl = "GitSignsDelete" },
				topdelete    = { text = '‾', hl = "GitSignsDelete" },
				changedelete = { text = '~', hl = "GitSignsChange" },
				untracked    = { text = '┆', hl = "GitSignsAdd" },
			},
			signs_staged_enable = true,
			signcolumn = true,
			numhl = true,
			linehl = false,
		})


		vim.keymap.set("n", "]c", function()
			require("gitsigns").nav_hunk("next")
		end)
		vim.keymap.set("n", "[c", function()
			require("gitsigns").nav_hunk("prev")
		end)
		vim.keymap.set("n", "<leader>hp", function()
			require("gitsigns").preview_hunk()
		end)

	end,
}
