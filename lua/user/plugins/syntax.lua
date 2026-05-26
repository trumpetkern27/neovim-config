-- nvim-treesitter `main` branch.
--
-- Heads-up: this is a completely different API from the old `master` branch.
-- `highlight = { enable = true }` and `indent = { enable = true }` no longer
-- exist; passing them does nothing. Highlighting must be started per buffer
-- via `vim.treesitter.start()`, typically from a FileType autocmd.
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	-- Load early so the install/auto-install runs before any code buffer
	-- opens. Lazy-loading on event = "BufReadPost" would race the first file
	-- opened from the cli (`nvim foo.cs`) and fail to highlight it.
	lazy = false,
	config = function()
		local ts = require("nvim-treesitter")

		ts.setup({
			-- Parsers go under nvim-data/site/parser/ by default; leave alone.
		})

		-- Install our standard set on first launch (idempotent -- skipped if
		-- already present). install() is async; that's fine.
		ts.install({
			"typescript",
			"javascript",
			"tsx",
			"c",
			"cpp",
			"c_sharp",
			"python",
			"rust",
			"asm",
			"lua",
			"luadoc",
			"vim",
			"vimdoc",
			"query",
			"markdown",
			"markdown_inline",
			"latex",
			"json",
			"toml",
			"yaml",
			"bash",
		})

		-- Start treesitter highlighting + folding + indent expressions for
		-- every buffer whose filetype has a parser. This is the new way to
		-- get the behaviour the old `highlight = { enable = true }` knob gave
		-- you for free.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("user_ts_attach", { clear = true }),
			callback = function(ev)
				local ft = vim.bo[ev.buf].filetype
				local lang = vim.treesitter.language.get_lang(ft)
				if not lang then
					return
				end
				-- language.add() returns true if the parser is loadable. It
				-- handles the "parser is installing right now" / "no parser
				-- exists" cases for us.
				local ok = pcall(vim.treesitter.language.add, lang)
				if not ok then
					return
				end
				pcall(vim.treesitter.start, ev.buf, lang)

				-- Treesitter-driven folds. Set per-buffer so it doesn't
				-- clobber buffers without a parser.
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.wo.foldmethod = "expr"
				vim.wo.foldenable = false -- open by default; toggle with zi
			end,
		})
	end,
}
