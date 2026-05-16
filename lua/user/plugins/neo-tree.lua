return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			default_component_configs = {
				container = {
					enable_character_fade = true,
				},
			},
			source_selector = {
				winbar = false,
			},
			name = {
				trailing_slash = false,
				use_get_status_colors = true,
			},
			window = {
				width = 30,
				mappings = {
					["l"] = "open",
					["h"] = "close_node",
					["<bs>"] = "navigate_up",
				},
			},
			filesystem = {
				bind_to_cwd = false,
				use_libuv_file_watcher = true,
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
				},
				follow_current_file = {
					enabled = true,
				},
			},
		})
		vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
		vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "none" })

		vim.keymap.set("n", "<leader>e", function()
			local root = vim.fs.dirname(vim.fs.find({ ".git" }, {upward = true })[1]) or vim.uv.cwd()
			require("neo-tree.command").execute({toggle = true, dir = root})
		end, {desc = "Toggle neo tree"})
	end,
}
