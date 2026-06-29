local colors = {
	bg = "#000000",
	fg = "#FFFFFF",
	yellow = "#ecbe7b",
	cyan = "#008080",
	darkblue = "#081633",
	green = "#98be65",
	orange = "#FF8800",
	violet = "#a9a1e1",
	magenta = "#c678dd",
	blue = "#51afef",
	red = "#ec5f67",
	white = "#FFFFFF",
	grey = "#bbc2cf",
}

local function git_branch()
	return vim.b.gitsigns_head or ""
end

local conditions = {
	buffer_not_empty = function()
		return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
	end,
	hide_in_width = function()
		return vim.fn.winwidth(0) > 80
	end,
	check_git_workspace = function()
		local filepath = vim.fn.expand("%:p:h")
		local gitdir = vim.fn.finddir(".git", filepath .. ";")
		return gitdir and #girdir > 0 and #gitdir < #filepath
	end,
}

local config = {
	options = {
		component_separators = '',
		section_separators = '',
		theme = {
			normal = { c = { fg = colors.fg, bg = colors. bg }},
			inactive = { c = { fg = colors.fg, bg = colors.bg }},
		},
	},
	sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		lualine_c = {},
		lualine_x = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		lualine_c = {},
		lualine_x = {},

	}
}

local function ins_left(component)
	table.insert(config.sections.lualine_c, component)
end

local function ins_right(component)
	table.insert(config.sections.lualine_x, component)
end

ins_left {
	function()
		return ''
	end,
	padding = { left = 0, right = 1},
}

ins_left {
	function()
		local mode = {
			n = 'NORMAL',
			i = 'INSERT',
			v = 'VISUAL',
			['\22'] = 'VISUAL BLOCK',
			V = 'VISUAL LINE',
			c = 'COMMAND',
			no = colors.red,
			s = 'SELECT',
			S = 'SELECT LINE',
			['\19'] = 'SELECT BLOCK',
			ic = colors.yellow,
			R = 'REPLACE',
			Rv = 'VIRTUAL REPLACE',
			cv = 'VIM EX',
			ce = 'EX',
			r = 'PROMPT',
			rm = 'MORE PROMPT',
			['r?'] = 'CONFIRM',
			['!'] = 'SHELL',
			t = 'TERMINAL',
		}
		return mode[vim.fn.mode()]
	end,
	color = function()
		local mode_fg = {
			n = colors.grey,
			i = colors.white,
			v = colors.blue,
			['\22'] = colors.blue,
			V = colors.blue,
			c = colors.magenta,
			no = colors.red,
			s = colors.orange,
			S = colors.orange,
			['\19'] = colors.orange,
			ic = colors.yellow,
			R = colors.red,
			Rv = colors.red,
			cv = colors.red,
			ce = colors.red,
			r = colors.cyan,
			rm = colors.cyan,
			['r?'] = colors.cyan,
			['!'] = colors.red,
			t = colors.white,
		}
		local mode_bg = {
			n = colors.bg,
			i = colors.bg,
			v = colors.bg,
			['\22'] = colors.bg,
			V = colors.bg,
			c = colors.bg,
			no = colors.bg,
			s = colors.bg,
			S = colors.bg,
			['\19'] = colors.bg,
			ic = colors.bg,
			R = colors.bg,
			Rv = colors.bg,
			cv = colors.bg,
			ce = colors.bg,
			r = colors.bg,
			rm = colors.bg,
			['r?'] = colors.bg,
			['!'] = colors.bg,
			t = colors.bg,
		}
		return {fg = mode_fg[vim.fn.mode()], bg = mode_bg[vim.fn.mode()] }
	end,
	padding = {left = 3, right = 1}
}

ins_left {
	'branch',
	color = function()
		local branch = git_branch()
		if branch:match("main") or branch:match("master") then
			return { fg = colors.red }
		elseif branch:match("feature") then
			return { fg = colors.violet }
		elseif branch:match("bug") then
			return {fg = colors.orange}
		elseif branch:match("development") then
			return {fg = colors.blue}
		elseif branch:match("experimental") then
			return {fg = colors.yellow}
		else
			return {fg = colors.fg}
		end
	end,
}
ins_left {
	'diff',
	symbols = {added = '🍪 ', modified = '🥐 ', removed = '🍌 '},
	diff_color = {
		added = {fg = colors.green},
		modified = { fg = colors.orange },
		removed = {fg = colors.red},
	},
	cond = conditions.hide_in_width,
}

ins_left {
	'filesize',
	cond = conditions.buffer_not_empty,
}
ins_left { 'location' }
ins_left {
	'diagnostics',
	sources = {'nvim_diagnostic'},
	symbols = {error = '🗿', warn = '🚩', info = '🍋'},
	diagnostics_color = {
		error = {fg = colors.red},
		warn = {fg = colors.yellow},
		info = {fg = colors.cyan},
	},
}

-- ins_left {
-- 	function()
-- 		local msg = "No Active Lsp"
-- 		local buf_ft = vim.api.nvim_get_option_value('filetype', {buf = 0})
-- 		local clients = vim.lsp.get_clients()
-- 		if next(clients) == nil then
-- 			return msg
-- 		end
-- 		for _, client in ipairs(clients) do
-- 			local filetypes = clients.config.filetypes
-- 			if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
-- 				return client.name
-- 			end
-- 		end
-- 		return msg
-- 	end,
-- 	icon = 'LSP: ',
-- 	color = {fg = colors.fg, gui = "bold"}
-- }

ins_right {
	'progress',
	color = {fg = colors.fg}
}
ins_right {
	function()
		return require("wpm-tracker").get_wpm_display()
	end,
	cond = function()
		return require("wpm-tracker").get_current_wpm() > 0
	end,
	color = { fg = "#3EFFDC" },
}
ins_right {
	"o:encoding",
	cond = conditions.hide_in_width,
	fmt = string.upper,
	cond = conditions.hide_in_width,
	color = {fg = colors.magenta},
}
-- ins_right {'filename', cond = conditions.buffer_not_empty, color = {fg = colors.magenta, gui = 'bold' },}
ins_right {
	'fileformat',
	cond = conditions.hide_in_width,
	fmt = string.upper,
	icons_enabled = false,
	color = {fg = colors.green, gui = 'bold'}
}



-- ins_right {
-- 	function()
-- 		return ''
-- 	end,
-- 	padding = {left = 1},
-- }

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {"nvim-tree/nvim-web-devicons"},
	config = function()
		require("lualine").setup(config)
	end,
}
