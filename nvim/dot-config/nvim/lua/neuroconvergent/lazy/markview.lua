return {
    "OXY2DEV/markview.nvim",
    lazy = false,
    priority = 49,
    opts = {
        auto_start = true,
        preview = {
		    icon_provider = "devicons", -- "mini" or "devicons"
    	},
        markdown = {
    }
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
}
