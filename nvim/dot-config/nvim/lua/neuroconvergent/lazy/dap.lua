return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui", -- optional: nice UI
			"theHamsta/nvim-dap-virtual-text", -- optional: inline variable values
			"mfussenegger/nvim-dap-python",
		},
		config = function()
			local dap = require("dap")

			-- dap-python handles the adapter setup automatically
			require("dap-python").setup("uv") -- use uv as Python executable

			-- Example dap-ui setup
			local dapui = require("dapui")
			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Keymaps
			vim.keymap.set("n", "<leader>dr", function()
				dap.continue()
			end, { desc = "DAP Continue" })
			vim.keymap.set("n", "<leader>do", function()
				dap.step_over()
			end, { desc = "DAP Step Over" })
			vim.keymap.set("n", "<leader>di", function()
				dap.step_into()
			end, { desc = "DAP Step Into" })
			vim.keymap.set("n", "<leader>dc", function()
				dap.step_out()
			end, { desc = "DAP Step Out" })
			vim.keymap.set("n", "<leader>db", function()
				dap.toggle_breakpoint()
			end, { desc = "DAP Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "DAP Conditional Breakpoint" })
		end,
	},
}
