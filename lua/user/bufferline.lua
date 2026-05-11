local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then return end

bufferline.setup {
	options = {
		numbers = "none",
		close_command = "bdelete! %d",
		right_mouse_command = "bdelete! %d",
		left_mouse_command = "buffer %d",
		indicator = { style = "icon", icon = "▎" },
		buffer_close_icon = "󰅖",
		modified_icon = "●",
		close_icon = "",
		left_trunc_marker = "",
		right_trunc_marker = "",
		diagnostics = "nvim_lsp",
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				highlight = "Directory",
				separator = true,
			},
		},
		show_buffer_close_icons = true,
		show_close_icon = true,
		color_icons = true,
	},
}
