local augroup = vim.api.nvim_create_augroup("user_autocmds", { clear = true } )

vim.api.nvim_create_autocmd("FileType", {
	pattern = "man",
	group = augroup,
	callback = function(args)
		vim.keymap.set("n", "gd", "<C-]>", { buffer = args.buf, remap = true, desc = "Jump to man page under cursor" } )
	end,
})
