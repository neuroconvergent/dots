require("neuroconvergent")

local presets = require("markview.presets");

require("markview").setup({
    markdown = {
        tables = presets.tables.rounded,
    }
});

vim.cmd.colorscheme 'catppuccin-mocha'



