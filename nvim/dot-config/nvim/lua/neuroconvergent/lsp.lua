-- LSP
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Set up all LSPs with default capabilities
local servers = {
    "lua_ls",
    "pyright",
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
    "ruff",
}

for _, server in ipairs(servers) do
    local ok, lsp = pcall(function()
        return lspconfig[server]
    end)
    if ok and lsp then
        lsp:setup({
            capabilities = capabilities,
        })
    else
        print("LSP server not found:", server)
    end
end

-- lsp automatic show diagnostic on hovering cursor for 2s on line
vim.diagnostic.config({
    float = {
        border = "rounded",
    },
})
vim.o.updatetime = 2000
vim.cmd([[autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })]])

lspconfig.clangd.setup({
    keys = {
        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
    },
    root_dir = function(fname)
        return require("lspconfig.util").root_pattern(
            "Makefile",
            "configure.ac",
            "configure.in",
            "config.h.in",
            "meson.build",
            "meson_options.txt",
            "build.ninja"
        )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname) or
        require(
            "lspconfig.util"
        ).find_git_ancestor(fname)
    end,
    capabilities = {
        offsetEncoding = { "utf-16" },
    },
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
    },
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    },
})

lspconfig.pyright.setup({
    capabilities = capabilities,
    settings = {
        pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
        },
        python = {
            analysis = {
                -- Ignore all files for analysis to exclusively use Ruff for linting
                ignore = { "*" },
            },
        },
    },
})
lspconfig.ruff.setup({})
