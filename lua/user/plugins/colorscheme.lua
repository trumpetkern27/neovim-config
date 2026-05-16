return {
	"miikanissi/modus-themes.nvim",
	priority = 1000,
	config = function()
		vim.cmd.colorscheme("modus_vivendi")

		vim.api.nvim_set_hl(0, "Normal", {bg = "#000000"})
		vim.api.nvim_set_hl(0, "LineNr", {bg = "#000000", fg = "#d31908"})
		vim.api.nvim_set_hl(0, "LineNrAbove", {bg = "#000000", fg = "#d31908"})
		vim.api.nvim_set_hl(0, "LineNrBelow", {bg = "#000000", fg = "#d31908"})
	end,
}

