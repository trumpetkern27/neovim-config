local status_ok, which_key = pcall(require, "which-key")
if not status_ok then return end

which_key.setup {
	delay = 500,
}

which_key.add {
	{ "<leader>g", group = "Git" },
	{ "<leader>gb", desc = "Blame line" },
	{ "<leader>gp", desc = "Preview hunk" },
	{ "<leader>gr", desc = "Reset hunk" },
	{ "<leader>e", desc = "File explorer" },
	{ "<leader>q", desc = "Quickfix list" },
}
