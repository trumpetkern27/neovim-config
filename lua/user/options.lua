local options = {
	backup = false, --creates backup file
	clipboard = "unnamedplus",
	cmdheight = 2,
	completeopt = {"menuone", "noselect"},
--	conceallevel = 0, -- `` visible in markdown files
	fileencoding = "utf-8",
	hlsearch = false, --highlight search
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
	timeoutlen = 1000, -- time to wait for mapped sequence to complete
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

vim.opt.shortmess:append "c"

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.cmd "set whichwrap+=<,>,[,],h,l" -- left-right movements don't wrap
vim.cmd [[set iskeyword+=-]]
vim.cmd [[set formatoptions-=cro]]
