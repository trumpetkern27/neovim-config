local options = {
	backup = false, --creates backup file
	clipboard = "unnamedplus",
	cmdheight = 2,
	completeopt = {"menuone", "noselect"},
--	conceallevel = 0, -- `` visible in markdown files
	fileencoding = "utf-8",
	hlsearch = true, --highlight search
	ignorecase = true,
	mouse = "a",
	pumheight = 10, --popup menu height
	showmode = true, -- shows -- INSERT --
	showtabline = 2, -- always show tabs
	smartcase = true,
	smartindent = true,
	splitbelow = true, -- forces sv to open below
	splitright = true, -- forces vs to open right
	swapfile = false, -- (doesn't) creates swap file
	termguicolors = true,
	timeoutlen = 300, -- time to wait for mapped sequence to complete
	undofile = true, -- creates undo file
	updatetime = 300, -- faster completion
	writebackup = false, 
	expandtab = false, -- if true, converts tabs to spaces
	shiftwidth = 4, --num spaces inserted per indendation
	tabstop = 4, -- tab space width
	cursorline = true, -- highlight current line
	number = true, -- numbered lines
	relativenumber = true, --relative numbered lines
	numberwidth = 4, -- number column width
	signcolumn = "yes", -- show sign column
	wrap = false, -- don't wrap lines
--	scrolloff = 8,
--	sidescrolloff = 8,
	guifont = "monospace:h17"
}

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("user_force_tabs", { clear = true }),
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.softtabstop = 0
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
	end,
})

vim.opt.shortmess:append "c"

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.cmd "set whichwrap+=<,>,[,],h,l" -- left-right movements don't wrap
vim.cmd [[set iskeyword+=-]]
vim.cmd [[set formatoptions-=cro]]

-- Make sure user-scoped tool dirs are visible to nvim's child processes
-- (mason cargo installs, dotnet global tools, etc.) even when nvim was
-- launched from a shell whose PATH was loaded before those dirs existed.
-- Windows only: on Linux/macOS these typically come from the login shell.
if vim.fn.has("win32") == 1 then
	local home = vim.env.USERPROFILE or vim.fn.expand("~")
	local extra = {
		home .. "\\.cargo\\bin",     -- rustup / cargo install --root
		home .. "\\.dotnet\\tools",  -- dotnet tool install -g
	}
	local sep = ";"
	local current = vim.env.PATH or ""
	for _, dir in ipairs(extra) do
		if vim.fn.isdirectory(dir) == 1 and not (sep .. current .. sep):find(sep .. dir .. sep, 1, true) then
			current = dir .. sep .. current
		end
	end
	vim.env.PATH = current
end
