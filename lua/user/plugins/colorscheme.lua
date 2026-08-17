return {
	"folke/tokyonight.nvim",
	-- "miikanissi/modus-themes.nvim",
	priority = 1000,
	config = function()
		vim.cmd.colorscheme("tokyonight-night")

		local bg
		if vim.fn.has('win32') == 1 then
			bg = "none"
		elseif vim.fn.has('linux') == 1 then
			bg = "none"
		else -- mac
			bg = "#000000"
		end

		
		vim.api.nvim_set_hl(0, "Normal", { bg = bg })
		vim.api.nvim_set_hl(0, "LineNr", { bg = bg, fg = "#23d5f0" })
		vim.api.nvim_set_hl(0, "LineNrAbove", { bg = bg, fg = "#23d5f0" })
		vim.api.nvim_set_hl(0, "LineNrBelow", { bg = bg, fg = "#23d5f0" })
		vim.api.nvim_set_hl(0, "CursorLineNr", { bg = bg, fg = "#c7ff60" })
		vim.api.nvim_set_hl(0, "NormalNC", {bg = bg})
		vim.api.nvim_set_hl(0, "WinSeparator", {fg = bg, bg = bg })
		vim.api.nvim_set_hl(0, "SignColumn", { bg =  bg })
		vim.api.nvim_set_hl(0, "SnacksNormal", { bg =  bg })
		vim.api.nvim_set_hl(0, "SnacksNormalNC", { bg =  bg })
		vim.api.nvim_set_hl(0, "StatusLine", { bg =  bg })
		vim.api.nvim_set_hl(0, "StatusLineNC", { bg =  bg })
		vim.api.nvim_set_hl(0, "TabLineFill", { bg =  bg })
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
