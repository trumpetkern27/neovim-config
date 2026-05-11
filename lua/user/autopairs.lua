local status_ok, autopairs = pcall(require, "nvim-autopairs")
if not status_ok then
	return
end

autopairs.setup {
	check_ts = true,
}

local cmp_autopairs = require "nvim-autopairs.completion.cmp"
local cmp_status_ok, cmp = pcall(require, "cmp")
if cmp_status_ok then
	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end
