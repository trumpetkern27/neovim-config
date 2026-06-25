return {
	"nvim-lualine/lualine.nvim",
	dependencies = {"nvim-tree/nvim-web-devicons"},
	config = function()
		require("lualine").setup({
			options = {
				theme = "solarized_dark",
				section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" },
			},
			sections = {
				lualine_x = {
					{
						function()
							return require("wpm-tracker").get_wpm_display()
						end,
						cond = function()
							return require("wpm-tracker").get_current_wpm() > 0
						end,
						color = { fg = "#3EFFDC" },
					},
					"encoding",
					"filetype",
				},
			}
		})
	end,
}
