return {
    "mason-org/mason-lspconfig.nvim",
    opts = {
        ensure_installed = {
            "lua_ls",
            "rust_analyzer",
            "shopify_theme_ls",
            "basedpyright",
            "ts_ls",
            "clangd",
            "html",
            "cssls",
            "texlab",
            "marksman",
            "yamlls",
            "jsonls",
            "taplo",
            "tinymist",
        },
        automatic_installation = true,
    },
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
}
