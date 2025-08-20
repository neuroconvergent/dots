return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
-- or                              , branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' },
			opts = {
				defaults = {
					file_ignore_patterns = {"node_modules"},
					preview = {
						treesitter = true,
					},
				},
			},
    }

