return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				-- Explicit rg invocation so live_grep doesn't silently fall
				-- back to nothing if telescope's auto-detection trips on
				-- the Windows winget shim path.
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden", -- include dotfiles (still respects .gitignore)
					"--glob=!.git/", -- but skip .git/
				},
			},
			pickers = {
				find_files = {
					hidden = true,
					-- Use rg for find_files too -- more consistent with grep
					-- behavior re: .gitignore handling, and avoids the slow
					-- builtin Lua walker on big trees.
					find_command = {
						"rg",
						"--files",
						"--hidden",
						"--glob=!.git/",
					},
				},
			},
		})

		-- Try to root a picker at the current buffer's project (nearest .git
		-- / .sln / .slnx / .csproj / Cargo.toml / package.json / pyproject.toml).
		-- Falls back to cwd if none found. This matters because live_grep
		-- otherwise greps from whatever you last `:cd`'d to, which is rarely
		-- what you want once you've :edit'd into another tree.
		local function project_root()
			local bufname = vim.api.nvim_buf_get_name(0)
			local start = (bufname ~= "" and vim.fs.dirname(bufname)) or vim.fn.getcwd()
			local marker = vim.fs.find({
				".git",
				".sln",
				".slnx",
				".csproj",
				"Cargo.toml",
				"package.json",
				"pyproject.toml",
			}, { upward = true, path = start, limit = 1 })[1]
			if marker then
				return vim.fs.dirname(marker)
			end
			return vim.fn.getcwd()
		end

		local function grep_project()
			builtin.live_grep({ cwd = project_root() })
		end

		local function files_project()
			builtin.find_files({ cwd = project_root() })
		end

		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { desc = desc })
		end

		-- `/`-family: project-wide grep on the main key, in-buffer fuzzy
		-- find on the shifted variant.
		map("<leader>/", grep_project, "Live grep in project")
		map("<leader>?", builtin.current_buffer_fuzzy_find, "Fuzzy find in current buffer")

		-- `f`-family: file pickers
		map("<leader>ff", files_project, "Find files in project")
		map("<leader>fF", builtin.find_files, "Find files (cwd)")
		map("<leader>fg", grep_project, "Grep in project") -- same as <leader>?, easier to type
		map("<leader>fG", builtin.live_grep, "Live grep (cwd)")
		map("<leader>fb", builtin.buffers, "Find buffers")
		map("<leader>fh", builtin.help_tags, "Help tags")
		map("<leader>fr", builtin.resume, "Resume last telescope picker")
		map("<leader>fw", function()
			builtin.grep_string({ cwd = project_root() })
		end, "Grep word under cursor (project)")

		-- Highlight group browser (you were asking about this earlier).
		map("<leader>fH", builtin.highlights, "Browse highlight groups")
	end,
}
