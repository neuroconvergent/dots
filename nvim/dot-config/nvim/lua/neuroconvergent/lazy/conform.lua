return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			-- LaTeX
			latex = { "latexindent" }, -- Requires latexindent installed

			-- Markdown and Markdown code blocks
			markdown = { "prettier", "injected" }, -- Prettier supports markdown formatting

			-- markdown and quarto code blocks
			quarto = { "prettier", "injected" },

			-- HTML
			html = { "prettier" },

			-- Liquid
			liquid = { "prettier" },

			-- YAML
			yaml = { "prettier" },

			-- JSON
			json = { "prettier" },

			-- BibTeX
			bibtex = { "bibtex-tidy" }, -- bibtex-tidy formatter for bibtex files

			-- Python
			python = { "black" }, -- Python formatter Black

			-- C++
			cpp = { "clang-format" }, -- clang-format for C++

			-- Rust
			rust = { "rustfmt" }, -- rustfmt for Rust

			-- Lua
			lua = { "stylua" }, -- stylua for Lua

            -- Shell
            sh = { "beautysh" },

			-- Typst
			typst = { "typstyle" },
		},
		formatters = {
			injected = {
				-- This tells conform to look at the language of the code block
				-- and use the corresponding formatter you've defined.
				options = {
					ignore_errors = true,
					lang_to_formatters = {
						python = { "black" }, -- or "ruff_format"
						cpp = { "clang-format" },
					},
				},
			},
			prettier = {
				---@diagnostic disable-next-line: unused-local
				prepend_args = function(self, ctx)
					if vim.bo[ctx.buf].filetype == "quarto" then
						return { "--parser", "markdown" }
					end
					return {}
				end,
			},
			-- This prevents Prettier from messing with line breaks in Quarto/MD
			args = { "--prose-wrap", "preserve" },
		},
	},
}
