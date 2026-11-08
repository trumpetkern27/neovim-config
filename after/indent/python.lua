-- Disable Neovim's bundled Python indenter and defer entirely to the global
-- tab settings + autoindent/smartindent configured in lua/user/options.lua.
--
-- Why this file has to exist at all: the stock indenter installs
--   indentexpr=python#GetIndent(v:lnum)
-- from $VIMRUNTIME/indent/python.vim, which is sourced in the 'filetypeindent'
-- pass -- AFTER the FileType autocmd that forces our tab settings. So the only
-- place that can reliably clear it is here, under after/indent, which runs
-- last of all.
--
-- The stock indenter is also actively wrong in this config: it uses synID() to
-- skip parens inside string literals, but treesitter highlighting (see
-- plugins/syntax.lua) turns legacy :syntax off, so synID() returns nothing. It
-- then miscounts the parentheses in regex string literals and emits a bogus
-- sub-tabstop indent, which noexpandtab writes out as literal spaces. Killing
-- it leaves autoindent (copy the previous line's real tabs) + smartindent
-- (one extra tab after if/for/while/else ...), both of which only ever emit
-- tabs under noexpandtab.

vim.bo.indentexpr = ""
vim.bo.indentkeys = ""
