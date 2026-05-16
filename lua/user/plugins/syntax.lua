return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            ensure_installed = {
                "typescript",
                "javascript",
                "c",
                "cpp",
                "c_sharp",
                "python",
                "rust",
                "asm",
                "lua",
                "vim",
                "vimdoc",
                "markdown",
                "markdown_inline",
                "latex",
            },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
}
