return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		-- Recommended for `ask()` and `select()`.
		-- Required for `snacks` provider.
		---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			-- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
			provider = {
				enabled = "snacks",
				snacks = {
					-- ...
				},
			},
		}

		-- Required for `opts.events.reload`.
		vim.o.autoread = true

		-- Recommended/example keymaps.

		vim.keymap.set({ "n", "x" }, "<leader>ao", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode" })

		vim.keymap.set({ "n", "x" }, "<leader>ac", function()
			require("opencode").select()
		end, { desc = "Execute opencode action…" })

		vim.keymap.set({ "n", "x" }, "ga", function()
			require("opencode").prompt("@this")
		end, { desc = "Add to opencode" })

		vim.keymap.set({ "n", "x" }, "<leader>abc", function()
			require("opencode").ask("@buffer: ", { submit = true })
		end, { desc = "Ask opencode with current buffer as context" })

		vim.keymap.set({ "n", "x" }, "<leader>aba", function()
			require("opencode").ask("@buffers: ", { submit = true })
		end, { desc = "Ask opencode with all buffers as context" })

		vim.keymap.set({ "n", "x" }, "<leader>ad", function()
			require("opencode").ask("@diagnostics: ", { submit = true })
		end, { desc = "Ask opencode with diagnostics as context" })

		vim.keymap.set({ "n", "x" }, "<leader>aq", function()
			require("opencode").ask("@quickfix: ", { submit = true })
		end, { desc = "Ask opencode with quickfix list as context" })

		vim.keymap.set({ "n", "x" }, "<leader>av", function()
			require("opencode").ask("@visible: ", { submit = true })
		end, { desc = "Ask opencode with visible text as context" })

		vim.keymap.set({ "n", "t" }, "<C-.>", function()
			require("opencode").toggle()
		end, { desc = "Toggle opencode" })

		vim.keymap.set("n", "<S-C-u>", function()
			require("opencode").command("session.half.page.up")
		end, { desc = "opencode half page up" })

		vim.keymap.set("n", "<S-C-d>", function()
			require("opencode").command("session.half.page.down")
		end, { desc = "opencode half page down" })

		-- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
		-- vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
		-- vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
	end,
}
