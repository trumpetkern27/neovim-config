vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local nvimtree = require("nvim-tree")

nvimtree.setup {
	on_attach = function(bufnr)
		local api = require "nvim-tree.api"
		local opts = function(desc)
			return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true}
		end

		api.config.mappings.default_on_attach(bufnr)

		vim.keymap.set("n", "l", api.node.open.edit, opts "Open/Expand")
		vim.keymap.set("n", "h", function()
			local api = require "nvim-tree.api"
			local node = api.tree.get_node_under_cursor()
			if node.nodes and node.nodes ~= {} then
				api.node.open.edit()
			else
				api.node.navigate.parent_close()
			end
		end, opts "Collapse")
		vim.keymap.set("n", "H", api.tree.collapse_all, opts "Collapse All")
	end,
	view = { width = 30 },
	renderer = {
		group_empty = true,
		icons = {
			show = {
				file = true,
				folder = true,
				folder_arrow = true,
				git = true,
			},
		},
	},
	filters = { dotfiles = false },
	git = { enable = true },
}
