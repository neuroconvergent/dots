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
	"jsonls",
	"texlab",
	"marksman",
	"yamlls",
	"jsonls",
	"tinymist",
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

lspconfig.clangd.setup{
    cmd = {"clangd", "--compile-commands-dir=build"}
}
