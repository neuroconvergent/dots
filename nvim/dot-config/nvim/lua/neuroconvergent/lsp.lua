-- Capabilities for completion
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Diagnostic configuration
vim.diagnostic.config({
	float = { border = "rounded" },
})
vim.o.updatetime = 1000
vim.cmd([[
  autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

-- Generic servers with default capabilities
local generic_servers = {
	"lua_ls",
	"ts_ls",
	"html",
	"cssls",
	"texlab",
	"marksman",
	"yamlls",
	"jsonls",
	"taplo",
	"tinymist",
	"solargraph",
}

for _, name in ipairs(generic_servers) do
	vim.lsp.config[name] = {
		default_config = {
			cmd = { name },
			filetypes = nil,
			root_dir = vim.loop.cwd,
			capabilities = capabilities,
		},
	}
	vim.lsp.enable(name)
end

-- Clangd setup
vim.lsp.config.clangd = {
	default_config = {
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--header-insertion=iwyu",
			"--completion-style=detailed",
			"--function-arg-placeholders",
			"--fallback-style=llvm",
		},
		capabilities = { offsetEncoding = { "utf-16" } },
		init_options = { usePlaceholders = true, completeUnimported = true, clangdFileStatus = true },
		root_dir = function(fname)
			local util = require("lspconfig.util")
			return util.root_pattern(
				"Makefile",
				"configure.ac",
				"configure.in",
				"config.h.in",
				"meson.build",
				"meson_options.txt",
				"build.ninja"
			)(fname) or util.root_pattern("compile_commands.json", "compile_flags.txt")(fname) or util.find_git_ancestor(
				fname
			)
		end,
		on_attach = function(client, bufnr)
			vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", { buffer = bufnr, silent = true })
		end,
	},
}
vim.lsp.enable("clangd")

-- Basedpyright setup
vim.lsp.config.basedpyright = {
	capabilities = capabilities,
	settings = {
		basedpyright = {
			settings = {
				disableOrganizeImports = true,
				basedpyright = {
					analysis = {
						-- ignore = { "*" },
						typeCheckingMode = "standard",
						diagnosticMode = "openFilesOnly",
						useLibraryCodeForTypes = true,
					},
				},
			},
		},
	},
}
vim.lsp.enable("basedpyright")

-- Ruff setup
vim.lsp.config.ruff = {
	default_config = {
		capabilities = capabilities,
	},
}
vim.lsp.enable("ruff")
