return {
	"nvimtools/none-ls.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				-- Formatting
				null_ls.builtins.formatting.prettier.with({
					filetypes = { "markdown", "html", "liquid", "toml", "yaml", "json" },
				}),
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.clang_format,
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.typstyle,
                null_ls.builtins.formatting.shfmt,

				-- Linters / Diagnostics
				null_ls.builtins.diagnostics.mypy, -- Python type checker
				-- you can add more here, like eslint_d for JS/TS

				-- Code actions
				null_ls.builtins.code_actions.gitsigns,
			},
		})
	end,
}
