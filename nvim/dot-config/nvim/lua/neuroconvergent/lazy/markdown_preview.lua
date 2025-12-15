return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	build = "cd app && yarn install",
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
		-- Define vimscript function for opening preview with Firefox profile
		vim.cmd([[
			function! OpenMarkdownPreview(url)
				call system('firefox -P preview ' . shellescape(a:url) . ' &')
			endfunction
		]])
		vim.g.mkdp_browserfunc = "OpenMarkdownPreview"
	end,
	ft = { "markdown" },
}
