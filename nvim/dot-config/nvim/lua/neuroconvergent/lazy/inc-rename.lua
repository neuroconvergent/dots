return {
	"smjonas/inc-rename.nvim",
	opts = {},
	config = function(_, opts)
		require("inc_rename").setup(opts)
		vim.keymap.set("n", "<leader>rn", function()
            -- <C-f> forces a split in normal mode to edit the command
            -- inspired by https://blog.viktomas.com/graph/neovim-lsp-rename-normal-mode-keymaps/
			return ":IncRename " .. vim.fn.expand("<cword>") .. "<C-f>"
		end, { expr = true, desc = "Rename symbol in normal mode"  })
	end,
}
