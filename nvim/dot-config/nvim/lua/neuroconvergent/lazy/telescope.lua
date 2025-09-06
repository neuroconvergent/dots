local ui_input_theme = require("telescope.themes").get_cursor()
ui_input_theme.initial_mode = "normal"
return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	-- or                              , branch = '0.1.x',
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	opts = {
		defaults = {
			file_ignore_patterns = { "node_modules" },
			preview = {
				treesitter = true,
			},
			layout_strategy = "horizontal",
		},
		extensions = {
			["ui-select"] = ui_input_theme,
		},
	},
	config = function(_, opts)
		require("telescope").setup(opts)
		require("telescope").load_extension("ui-select")
	end,
}
