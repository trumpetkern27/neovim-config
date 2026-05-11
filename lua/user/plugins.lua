local fn = vim.fn

-- install packer plugin manager
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system {
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	}
	print "Installing packer close and reopen Neovim..."
	vim.cmd [[packadd packer.nvim]]
end

vim.cmd [[
	augroup packer_user_config
		autocmd!
		autocmd BufWritePost plugins.lua source <afile> | PackerSync
	augroup end
]]

local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- make it a window
packer.init {
	display = {
		open_fn = function()
			return require("packer.util").float {border = "rounded"}
		end,
	},
}

-- install plugins here
return packer.startup(function(use)
	-- plugins here
	use "wbthomason/packer.nvim" -- let packer manage itself
	use "nvim-lua/popup.nvim" -- implementation of popup api from vim in Neovim
	use "nvim-lua/plenary.nvim" -- useful lua functions used in lots of plugins
	use "miikanissi/modus-themes.nvim" -- colour themes

	-- cmp plugins
	use "hrsh7th/nvim-cmp" -- The completion plugin
	use "hrsh7th/cmp-buffer" -- buffer completions
	use "hrsh7th/cmp-path" -- path completions
	use "hrsh7th/cmp-cmdline" -- cmdline completions
	use "hrsh7th/cmp-nvim-lua"
	use "hrsh7th/cmp-nvim-lsp"
	use "saadparwaiz1/cmp_luasnip" -- snippet completions

	-- snippets
	use "L3MON4D3/LuaSnip" --snippet engine
	use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

	-- lsp
	use "neovim/nvim-lspconfig" -- enable LSP
	use "williamboman/mason.nvim"
	use "williamboman/mason-lspconfig.nvim"
	use "nvimtools/none-ls.nvim"

	-- telescope
	use "nvim-telescope/telescope.nvim"
	use "nvim-telescope/telescope-media-files.nvim"

	-- treesitter
	use {
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	}

	-- undo tree
	use "mbbill/undotree"

	-- autopairs
	use "windwp/nvim-autopairs"

	--nvim tree
	use "nvim-tree/nvim-tree.lua"
	use "nvim-tree/nvim-web-devicons"

	use "nvim-lualine/lualine.nvim"
	use "akinsho/bufferline.nvim"
	use "lewis6991/gitsigns.nvim"

	use "kylechui/nvim-surround"

	use "folke/flash.nvim"

	use "tpope/vim-fugitive"
	use "folke/which-key.nvim"
	use "akinsho/toggleterm.nvim"

	-- snippets
	-- automatically set up config after cloning packer.nvim
	-- put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)

