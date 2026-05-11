local status_ok, flash = pcall(require, "flash")
if not status_ok then return end

flash.setup()

local opts = { noremap = true, silent = true }
vim.keymap.set({ "n", "x", "o" }, "s", function() flash.jump() end, opts)
vim.keymap.set({ "n", "x", "o" }, "S", function() flash.treesitter() end, opts)
