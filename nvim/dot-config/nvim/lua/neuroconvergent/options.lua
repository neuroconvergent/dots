vim.o.relativenumber = true
vim.o.number = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.signcolumn = yes
vim.cmd('syntax on')
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.mouse = "a"
vim.o.termguicolors = true
vim.cmd [[let &t_8f = "\e[38;2;%lu;%lu;%lum"]]
vim.cmd [[let &t_8b = "\e[48;2;%lu;%lu;%lum"]]
vim.o.encoding = 'UTF-8'
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.scrolloff = 8
vim.o.incsearch = true
vim.cmd[[set noswapfile]]
vim.cmd[[set nobackup]]
local prefix = vim.fn.expand("$HOME/.vim/")
vim.o.undodir = prefix .. "undodir"
vim.o.undofile = true
vim.o.smartindent = true
vim.o.hidden = true
vim.o.wrap = false
vim.o.breakindent = true
--vim.opt.showbreak = string.rep(" ", 3) -- Make it so that long lines wrap smartly
vim.o.linebreak = true
vim.cmd[[set whichwrap+=<,>,h,l]]
vim.o.foldenable = true
vim.o.foldmethod = 'syntax'
--vim.cmd[[set list lcs=tab:\-> ]]
vim.cmd[[set clipboard=unnamedplus]]
vim.cmd[[set shortmess+=c]]
vim.o.signcolumn = 'yes'
-- vim.o.winborder = 'rounded'
vim.g.vim_markdown_folding_disabled = 1
vim.api.nvim_set_hl(0, "Normal", {bg = "none"})
vim.api.nvim_set_hl(0, "NormalNC", {bg = "none"})
vim.api.nvim_set_hl(0, "EndOfBuffer", {bg = "#ffffff"})
vim.cmd[[highlight Normal guibg=NONE]]

vim.o.autoread = true
vim.o.autochdir = false

vim.opt.spell = true                -- enable spellcheck
vim.opt.spelllang = { "en_gb" }     -- set UK English
vim.opt.linebreak = true
vim.opt.wrapmargin = 10
