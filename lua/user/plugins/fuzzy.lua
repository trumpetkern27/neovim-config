return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("telescope").setup()
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "find files" })
		vim.keymap.set("n", "<leader>/", builtin.live_grep, { desc = "live grep" })
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "find buffers" })
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "help tags" })
	end,
}
