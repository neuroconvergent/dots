return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	priority = 49,
    filetype = { "markdown", "quarto", "opencode_output"  },
	opts = {
		auto_start = true,
		preview = {
			icon_provider = "devicons", -- "mini" or "devicons"
			modes = { "n", "no", "c" },
			hybrid_modes = { "n", "no", "c" },
		},
		markdown = {},
	},
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
