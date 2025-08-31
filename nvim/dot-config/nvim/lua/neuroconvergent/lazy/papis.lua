return {
	"jghauser/papis.nvim",
	ft = { "markdown", "latex", "norg", "typst" },
	dependencies = {
		"kkharji/sqlite.lua",
		"MunifTanjim/nui.nvim",
		"pysan3/pathlib.nvim",
		"nvim-neotest/nvim-nio",
		-- if not already installed, you may also want:
		"hrsh7th/nvim-cmp",

		-- Choose one of the following two if not already installed:
		"nvim-telescope/telescope.nvim",
		-- "folke/snacks.nvim",
	},
	config = function()
		require("papis").setup({
			enable_keymaps = true,
			init_filetypes = { "markdown", "tex", "norg", "typst" },
			cite_formats = {
				markdown = {
					start_str = "[",
					end_str = "]",
					ref_prefix = "@",
					separator_str = "; ",
				},
			},
			["search"] = {
				enable = true,
				provider = "telescope",
			},
			["completion"] = {
				enable = true,
				provider = "cmp",
			},
		})
	end,
}
