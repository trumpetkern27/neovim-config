local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then return end

gitsigns.setup {
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete =	{ text = "" },
		changedelete = { text = "▎" },
	},
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns
		local opts = { noremap = true, silent = true, buffer = bufnr }
		vim.keymap.set("n", "]g", gs.next_hunk, opts)
		vim.keymap.set("n", "[g", gs.prev_hunk, opts)
		vim.keymap.set("n", "<leader>gp", gs.preview_hunk, opts)
		vim.keymap.set("n", "<leader>gb", gs.blame_line, opts)
		vim.keymap.set("n", "<leader>gr", gs.reset_hunk, opts)
	end,
}
