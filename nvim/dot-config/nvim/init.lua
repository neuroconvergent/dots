require("neuroconvergent")

local presets = require("markview.presets");

require("markview").setup({
    markdown = {
        tables = presets.tables.rounded,
    }
});

vim.cmd.colorscheme 'catppuccin-mocha'

vim.cmd [[augroup DebugWrite
  autocmd!
  autocmd BufWritePre,BufWritePost *.md echom "Write:" expand('%:p')
augroup END]]


