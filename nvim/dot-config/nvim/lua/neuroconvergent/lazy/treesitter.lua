return {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    dependencies = { "OXY2DEV/markview.nvim" },
}

