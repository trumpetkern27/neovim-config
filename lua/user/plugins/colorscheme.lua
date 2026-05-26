return {
	"folke/tokyonight.nvim",
	-- "miikanissi/modus-themes.nvim",
	priority = 1000,
	config = function()
		vim.cmd.colorscheme("tokyonight-night")

		vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
		vim.api.nvim_set_hl(0, "LineNr", { bg = "#000000", fg = "#d31908" })
		vim.api.nvim_set_hl(0, "NormalNC", {bg = "#000000"})
		vim.api.nvim_set_hl(0, "WinSeparator", {fg = "#000000", bg = "#000000"})
		vim.api.nvim_set_hl(0, "LineNrAbove", { bg = "#000000", fg = "#d31908" })
		vim.api.nvim_set_hl(0, "LineNrBelow", { bg = "#000000", fg = "#d31908" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "#000000" })
		-- vim.api.nvim_set_hl(0, "WarningMsg", { fg = "#d31908" })
		-- vim.api.nvim_set_hl(0, "Normal", { fg = "#FFFFFF" })
		-- vim.api.nvim_set_hl(0, "Number", { fg = "#14a0e5" })
		-- vim.api.nvim_set_hl(0, "String", { fg = "#20c060" })
		-- vim.api.nvim_set_hl(0, "Keyword", { fg = "#ff8cb0", italic = true })
		-- vim.api.nvim_set_hl(0, "Function", { fg = "#9c5be5" })
		-- vim.api.nvim_set_hl(0, "Include", { fg = "#a0c0ae" })
		-- vim.api.nvim_set_hl(0, "Operator", {fg = "#00d0ff"})
		-- vim.api.nvim_set_hl(0, "@type", {fg = "#f0a030"})
	end,
}
