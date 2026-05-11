return {
	settings = {
		Lua = {
			diagnostics = {
				globals = {"vim"},
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
				maxPreload = 100,
				preloadFileSize = 10000,
				checkThirdParty =- false,
			},
			telemetry = { enable = false },
		},
	},
}
