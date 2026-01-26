-- Capabilities for completion
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Diagnostic configuration
-- vim.diagnostic.config({
-- 	float = { border = "rounded" },
-- })
-- vim.o.updatetime = 1000
-- vim.cmd([[
--   autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
-- ]])

vim.diagnostic.config({
	virtual_text = true,
	-- virtual_lines = { current_line = true },
	underline = true,
	update_in_insert = false,
})

-- local og_virt_text
-- local og_virt_line
-- vim.api.nvim_create_autocmd({ "CursorMoved", "DiagnosticChanged" }, {
-- 	group = vim.api.nvim_create_augroup("diagnostic_only_virtlines", {}),
-- 	callback = function()
-- 		if og_virt_line == nil then
-- 			og_virt_line = vim.diagnostic.config().virtual_lines
-- 		end
--
-- 		-- ignore if virtual_lines.current_line is disabled
-- 		if not (og_virt_line and og_virt_line.current_line) then
-- 			if og_virt_text then
-- 				vim.diagnostic.config({ virtual_text = og_virt_text })
-- 				og_virt_text = nil
-- 			end
-- 			return
-- 		end
--
-- 		if og_virt_text == nil then
-- 			og_virt_text = vim.diagnostic.config().virtual_text
-- 		end
--
-- 		local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
--
-- 		if vim.tbl_isempty(vim.diagnostic.get(0, { lnum = lnum })) then
-- 			vim.diagnostic.config({ virtual_text = og_virt_text })
-- 		else
-- 			vim.diagnostic.config({ virtual_text = false })
-- 		end
-- 	end,
-- })

-- vim.api.nvim_create_autocmd("ModeChanged", {
-- 	group = vim.api.nvim_create_augroup("diagnostic_redraw", {}),
-- 	callback = function()
-- 		pcall(vim.diagnostic.show)
-- 	end,
-- })

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
	"fortls",
	"bashls",
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
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--fallback-style=llvm",
	},
	capabilities = { offsetEncoding = { "utf-16" } },
	init_options = { usePlaceholders = true, completeUnimported = true, clangdFileStatus = true },
	root_markers = {
		"Makefile",
		"configure.ac",
		"configure.in",
		"config.h.in",
		"meson.build",
		"meson_options.txt",
		"build.ninja",
	}, -- end,
	keys = {
		{ "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
	},
}

local deal_project_roots = {
	"/home/neuroconvergent/Programming/KMC-AM",
}

local function set_deal_clangd_config()
	for _, root in ipairs(deal_project_roots) do
		if vim.fn.getcwd() == root then
			vim.lsp.config.clangd = {
				cmd = {
					"docker",
					"run",
					"--rm",
					"-i",
					"-v",
					"/home/neuroconvergent:/home/neuroconvergent",
					"-w",
					root,
					"neuroconvergent/deal-ii",
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--fallback-style=llvm",
				},
			}
			break
		else -- Reset command if moving to dir that is not deal.ii
			vim.lsp.config.clangd = {
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--fallback-style=llvm",
				},
			}
		end
	end
end

-- initial setup
set_deal_clangd_config()

-- update clangd command on changing cwd
vim.api.nvim_create_autocmd("DirChanged", {
	callback = function()
		set_deal_clangd_config()
		vim.lsp.enable("clangd")
	end,
})

vim.lsp.enable("clangd")

-- Basedpyright setup
vim.lsp.config.basedpyright = {
	default_config = {
		cmd = { "basedpyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_dir = function(fname)
			local util = require("lspconfig.util")
			return util.root_pattern(
				"pyproject.toml",
				"setup.py",
				"setup.cfg",
				"requirements.txt",
				"Pipfile",
				"pyrightconfig.json"
			)(fname) or util.find_git_ancestor(fname)
		end,
		capabilities = capabilities,
	},
	settings = {
		basedpyright = {
			disableOrganizeImports = true,
			analysis = {
				autoSearchPaths = true,
				typeCheckingMode = "standard",
				diagnosticMode = "workspace",
				useLibraryCodeForTypes = true,
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

vim.lsp.config.rust_analyzer = {
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			cargo = {
				allFeatures = true,
			},
			checkOnSave = {
				command = "clippy",
			},
			rustup = {
				enable = true,
			},
		},
	},
}
vim.lsp.enable("rust_analyzer")
