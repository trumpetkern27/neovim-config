return {
	"folke/flash.nvim",
	event = "VeryLazy",
	config = function()
		require("flash").setup()
		vim.keymap.set({"n", "x", "o" }, "s", function() require("flash").jump() end, {desc = "Flash"})
	end,
}
