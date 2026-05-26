-- xcodebuild.nvim drives `xcrun`/`xcodebuild` for iOS / macOS app development.
-- It's macOS-only; the plugin won't function on Windows or Linux. Gating with
-- `cond` keeps lazy.nvim from cloning it on non-Apple machines too.
return {
	"wojciech-kulik/xcodebuild.nvim",
	cond = function()
		return vim.fn.has("mac") == 1
	end,
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"MunifTanjim/nui.nvim",
		"mfussenegger/nvim-dap",
	},
	config = function()
		require("xcodebuild").setup({
			code_coverage = {
				enabled = true,
			},
		})

		vim.keymap.set("n", "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", { desc = "Toggle Xcodebuild Logs" })
		vim.keymap.set("n", "<leader>xb", "<cmd>XcodebuildBuild<cr>", { desc = "Build Project" })
		vim.keymap.set("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", { desc = "Build & Run Project" })
		vim.keymap.set("n", "<leader>xt", "<cmd>XcodebuildTest<cr>", { desc = "Run Tests" })
		vim.keymap.set("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>", { desc = "Run This Test Class" })
		vim.keymap.set("n", "<leader>X", "<cmd>XcodebuildPicker<cr>", { desc = "Show All Xcodebuild Actions" })
		vim.keymap.set("n", "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", { desc = "Select Device" })
		vim.keymap.set("n", "<leader>xp", "<cmd>XcodebuildSelectTestPlan<cr>", { desc = "Select Test Plan" })
		vim.keymap.set("n", "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", { desc = "Toggle Code Coverage" })
		vim.keymap.set(
			"n",
			"<leader>xC",
			"<cmd>XcodebuildShowCodeCoverageReport<cr>",
			{ desc = "Show Code Coverage Report" }
		)
		vim.keymap.set("n", "<leader>xq", "<cmd>Telescope quickfix<cr>", { desc = "Show QuickFix List" })

		-- Xcodebuild's DAP integration -- iOS sim / device debugging through
		-- nvim-dap. These keymaps used to live in nvim-dap.lua but are
		-- xcodebuild-specific, so they belong here behind the macOS gate.
		local xcdap = require("xcodebuild.integrations.dap")
		vim.keymap.set("n", "<leader>dd", xcdap.build_and_debug, { desc = "Build & Debug (Xcode)" })
		vim.keymap.set("n", "<leader>dD", xcdap.debug_without_build, { desc = "Debug Without Building (Xcode)" })
		vim.keymap.set("n", "<leader>dt", xcdap.debug_tests, { desc = "Debug Tests (Xcode)" })
		vim.keymap.set("n", "<leader>dT", xcdap.debug_class_tests, { desc = "Debug Class Tests (Xcode)" })
	end,
}
