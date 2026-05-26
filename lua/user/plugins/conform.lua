-- Format-on-save is intentionally OFF. With it on, conform falls back to
-- vim.lsp.buf.format() for any filetype that has no configured formatter --
-- which means roslyn aggressively rewrites C# braces to Allman style, clangd
-- rewrites tabs to spaces, etc. Manual format only: `<leader>mp`.
--
-- format_after_save is also off as belt-and-suspenders -- in some setups
-- format_on_save can be overridden by user buffer flags but format_after_save
-- runs unconditionally.
return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	cmd = { "ConformInfo" },
	config = function()
		local conform = require("conform")

		conform.setup({
			format_on_save = false,
			format_after_save = false,
			log_level = vim.log.levels.ERROR,
			formatters_by_ft = {
				swift = { "swiftformat" },
				-- Add more here as you want them. Anything missing falls
				-- through to "no formatter for this buffer" -- which is the
				-- correct, non-destructive behavior.
			},
			-- Per-formatter argument overrides. These only apply if conform
			-- actually invokes the formatter (manual format, or if you ever
			-- add the formatter to formatters_by_ft).
			formatters = {
				["clang-format"] = {
					prepend_args = {
						"--style={"
							.. "BasedOnStyle: LLVM, "
							.. "UseTab: Always, "
							.. "IndentWidth: 4, "
							.. "TabWidth: 4, "
							.. "ColumnLimit: 120"
							.. "}",
					},
				},
				shfmt = {
					prepend_args = { "-i", "0" },
				},
				prettier = {
					prepend_args = { "--use-tabs", "--tab-width", "4" },
				},
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true, -- ok to LSP-format when YOU ask for it
				async = false,
				timeout_ms = 1500,
			})
		end, { desc = "Format file or range" })
	end,
}
