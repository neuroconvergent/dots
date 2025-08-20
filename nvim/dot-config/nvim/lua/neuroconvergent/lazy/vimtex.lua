return {
  "lervag/vimtex",
  lazy = false,     -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here, e.g.
    vim.g.vimtex_compiler_latexmk = {
    	build_dir = '',
    	callback = 1,
    	continuous = 1,
    	executable = 'latexmk',
    	options = {
    		'-pdf',								 -- generate PDF
    		'-pdflatex=lualatex -synctex=1 -interaction=nonstopmode',	-- use lualatex as pdflatex cmd
    	}
    }
  end
}
