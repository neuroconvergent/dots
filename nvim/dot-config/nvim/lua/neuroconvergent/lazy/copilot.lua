return {
	"github/copilot.vim",
	init = function()
		vim.keymap.set("i", "<S-Tab>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
		})
		vim.g.copilot_no_tab_map = true
		vim.cmd([[let g:copilot_filetypes = { '*': v:false }]])
	end,
}
