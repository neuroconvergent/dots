local colors = require("catppuccin.palettes").get_palette()
return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
        -- TODO: Palette Test
        -- WARN: Palette Test
        -- PERF: Palette Test
        -- HACK: Palette Test
        -- NOTE: Palette Test
        -- TEST: Palette Test
		colors = {
			error = { "DiagnosticError", "ErrorMsg", colors.red },
			warning = { "DiagnosticWarn", "WarningMsg", colors.yellow },
			info = { "DiagnosticInfo", colors.sapphire },
			hint = { "DiagnosticHint", colors.green },
			default = { "Identifier", colors.mauve },
			test = { "Identifier", colors.crust },
		},
	},
}
