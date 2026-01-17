return {
	"nvimtools/none-ls.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				-- Formatting
				null_ls.builtins.formatting.prettier.with({
					filetypes = { "markdown", "html", "liquid", "toml", "yaml", "json", "quarto" },
				}),
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.clang_format,
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.typstyle,
				null_ls.builtins.formatting.shfmt,
				null_ls.builtins.formatting.rubocop,

				-- Linters / Diagnostics
				null_ls.builtins.diagnostics.mypy.with({
					command = "mypy",
					args = {
						"--show-column-numbers",
						"--ignore-missing-imports",
						"--strict", -- or relax this if you want
						"--python-executable",
						vim.fn.exepath("python"),
						"$FILENAME",
					},
				}),
				-- you can add more here, like eslint_d for JS/TS
				-- Add cbfmt for markdown and quarto
				null_ls.builtins.formatting.cbfmt.with({
					filetypes = { "markdown", "quarto" },
				}),

				-- Code actions
				null_ls.builtins.code_actions.gitsigns,
			},
		})
	end,
}
