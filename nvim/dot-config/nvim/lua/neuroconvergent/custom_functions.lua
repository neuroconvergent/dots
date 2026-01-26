-- BIG Hover window (75% screen)
local function big_hover()
	local params = vim.lsp.util.make_position_params()

	vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result)
		if err or not (result and result.contents) then
			vim.notify("No hover information", vim.log.levels.INFO)
			return
		end

		local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

		local width = math.floor(vim.o.columns * 0.75)
		local height = math.floor(vim.o.lines * 0.75)

		local win = vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			style = "minimal",
			border = "rounded",
			width = width,
			height = height,
			row = math.floor((vim.o.lines - height) / 2),
			col = math.floor((vim.o.columns - width) / 2),
		})

		-- Set options after window is open to ensure plugins attach correctly
		vim.bo[buf].filetype = "markdown"
		vim.bo[buf].buftype = "acwrite"
		vim.bo[buf].bufhidden = "wipe"
		vim.bo[buf].modifiable = false
		vim.bo[buf].readonly = true

		-- Explicitly trigger FileType for plugins like markview
		vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter" }, {
			buffer = buf,
			callback = function()
				vim.cmd("Markview hybridDisable")
			end,
			once = true,
		})
        vim.api.nvim_exec_autocmds("FileType", { buffer = buf })

		local function close()
			if vim.api.nvim_win_is_valid(win) then
				pcall(vim.api.nvim_win_close, win, true)
			end
			if vim.api.nvim_buf_is_loaded(buf) then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end

		vim.keymap.set("n", "<Esc>", close, { buffer = buf, silent = true })
		vim.keymap.set("n", "q", close, { buffer = buf, silent = true })
		vim.keymap.set("n", "<C-w>c", close, { buffer = buf, silent = true })
	end)
end

-- BIG Hover window in vertical split (Right side, width 100)
local function vsplit_hover()
	local params = vim.lsp.util.make_position_params()

	vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result)
		if err or not (result and result.contents) then
			vim.notify("No hover information", vim.log.levels.INFO)
			return
		end

		local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
		local orig_win = vim.api.nvim_get_current_win()

		-- Use vnew to create a clean new buffer/window immediately
		vim.cmd("rightbelow vertical 70 vnew")
		local win = vim.api.nvim_get_current_win()
		local buf = vim.api.nvim_get_current_buf()

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

		-- Set options and trigger FileType
		vim.bo[buf].filetype = "markdown"
		vim.bo[buf].buftype = "acwrite"
		vim.bo[buf].bufhidden = "wipe"
		vim.bo[buf].modifiable = false
		vim.bo[buf].readonly = true

		vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter" }, {
			buffer = buf,
			callback = function()
				vim.cmd("Markview hybridDisable")
			end,
			once = true,
		})
		vim.api.nvim_exec_autocmds("FileType", { buffer = buf })

		-- Return cursor to original window
		vim.api.nvim_set_current_win(orig_win)

		local function close()

			if vim.api.nvim_win_is_valid(win) then
				pcall(vim.api.nvim_win_close, win, true)
			end
			if vim.api.nvim_buf_is_loaded(buf) then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end

		vim.keymap.set("n", "<Esc>", close, { buffer = buf, silent = true })
		vim.keymap.set("n", "q", close, { buffer = buf, silent = true })
		vim.keymap.set("n", "<C-w>c", close, { buffer = buf, silent = true })
	end)
end

return {
	big_hover = big_hover,
	vsplit_hover = vsplit_hover,
}
