-- Terminal mode
vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { noremap = true, desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-q>", "<C-\\><C-n>", { noremap = true, desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", { noremap = true, desc = "Exit terminal mode and manipulate buffer" })

-- Remap scroll to centre window
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Tab manipulation
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>")
vim.keymap.set("n", "<M-w>", ":bdel<CR>")
vim.keymap.set("n", "<M-t>", ":enew<CR>")

-- Clear search completely
vim.keymap.set("n", "<C-f>", ':let @/ = "" <CR>')
-- Remove highlight search
vim.keymap.set("n", "<Esc>", "<Cmd>noh<CR>", { desc = "Remove search highlight", remap = false })

-- Warped line motion
vim.keymap.set("n", "<C-j>", "gj")
vim.keymap.set("n", "<C-k>", "gk")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", ":Telescope find_files hidden=true <CR>", default_opts) -- Find Files
vim.keymap.set("n", "<leader>fr", ":Telescope oldfiles hidden=true <CR>", default_opts)
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", default_opts)
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", default_opts)
vim.keymap.set("n", "<leader>fgc", ":Telescope git_bcommits<CR>", default_opts)
vim.keymap.set("n", "<leader>fgs", ":Telescope git_status<CR>", default_opts)
vim.keymap.set("n", "<leader>fss", ":Telescope grep_string<CR>", default_opts)
vim.keymap.set("n", "<leader>fsg", ":Telescope live_grep<CR>", default_opts)

-- Snacks Notifications (Telescope)
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values
local widths = {
	time = 8,
	title = 15,
	icon = nil,
	level = nil,
	message = nil,
}

local displayer = entry_display.create({
	separator = " ",
	items = {
		{ width = widths.time },
		{ width = widths.title },
		{ width = widths.icon },
		{ width = widths.level },
		{ width = widths.message },
	},
})
local levels = { "Info", "Warn", "Error", "Debug", "Trace" }
for _, lvl in ipairs(levels) do
	vim.api.nvim_set_hl(0, "SnacksNotifierIcon" .. lvl, { link = "DiagnosticSign" .. lvl })
	vim.api.nvim_set_hl(0, "SnacksNotifierTitle" .. lvl, { link = "DiagnosticVirtualText" .. lvl })
	vim.api.nvim_set_hl(0, "SnacksNotifierBorder" .. lvl, { link = "FloatBorder" })
	vim.api.nvim_set_hl(0, "SnacksNotifierFooter" .. lvl, { link = "Comment" })
	vim.api.nvim_set_hl(0, "SnacksNotifier" .. lvl, { link = "NormalFloat" })
end
local function snacks_notifications(opts)
	opts = opts or {}
	local notifications = Snacks.notifier.get_history() or {} -- Fallback to empty if no history

	-- Reverse so newest is at the bottom
	local reversed = {}
	for i = #notifications, 1, -1 do
		table.insert(reversed, notifications[i])
	end
	notifications = reversed

	pickers
		.new(opts, {
			prompt_title = "Snacks Notifications",
			finder = finders.new_table({
				results = notifications,
				entry_maker = function(entry)
					local time = os.date("%T", entry.added)
					local sev = (entry.severity or entry.level) or ""
					local title = entry.title or ""
					local msg = entry.msg or ""
					local icon = entry.icon or ""
					local short_msg = string.sub(msg, 1, 30) .. (#msg > 30 and "..." or "")
					return {
						value = entry,
						display = function(_)
							return displayer({
								{ time, "SnacksPickerTime" },
								{ title, "SnacksNotifierHistoryTitle" },
								{
									icon,
									"SnacksNotifierIcon"
										.. (entry.level and entry.level:gsub("^%l", string.upper) or "Info"),
								},
								{
									string.upper(sev),
									"SnacksNotifierTitle"
										.. (entry.level and entry.level:gsub("^%l", string.upper) or "Info"),
								},
								{ short_msg, "SnacksPickerNotificationMessage" },
							})
						end,
						ordinal = (entry.title or "") .. " " .. (entry.msg or ""), -- Match nvim-notify ordinal formatting
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if not selection or not selection.value then
						return
					end

					local notif = selection.value
					local msg = notif.msg or ""
					local title = notif.title or "Notification"
					local level = notif.level or notif.severity or "info"
					local icon = notif.icon or ""
					local time = os.date("%T", notif.added or os.time())
					local Level = level:gsub("^%l", string.upper)

					-- Prepare content
					local body_lines = vim.split(msg, "\n")
					local content_width = 0
					for _, line in ipairs(body_lines) do
						content_width = math.max(content_width, vim.fn.strdisplaywidth(line))
					end

					-- Header: icon level title time
					local header_text = string.format("%s %s   %s   %s", icon, Level, title, time)
					content_width = math.max(content_width, vim.fn.strdisplaywidth(header_text))
					local header_line = header_text
						.. string.rep(" ", content_width - vim.fn.strdisplaywidth(header_text))
					local separator_line = string.rep("─", content_width)

					-- Create buffer
					local buf = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, { header_line, separator_line, unpack(body_lines) })
					vim.bo[buf].filetype = "markdown"

					-- Highlight header parts
					local ns = vim.api.nvim_create_namespace("SnacksNotifFloat")
					local col = 0
					vim.api.nvim_buf_add_highlight(buf, ns, "SnacksNotifierIcon" .. Level, 0, col, col + #icon)
					col = col + #icon + 1
					vim.api.nvim_buf_add_highlight(buf, ns, "SnacksNotifierTitle" .. Level, 0, col, col + #Level)
					col = col + #Level + 3
					vim.api.nvim_buf_add_highlight(buf, ns, "SnacksNotifierHistoryTitle", 0, col, col + #title)
					col = col + #title + 3
					vim.api.nvim_buf_add_highlight(buf, ns, "SnacksPickerTime", 0, col, col + #time)

					-- Floating window size
					local width = content_width + 2
					local height = #body_lines + 2
					local row = math.floor((vim.o.lines - height) / 2)
					local col = math.floor((vim.o.columns - width) / 2)

					-- Border highlight
					local border_hl = "SnacksNotifBorder" .. Level
					vim.api.nvim_set_hl(0, border_hl, {
						fg = vim.api.nvim_get_hl_by_name("DiagnosticSign" .. Level, true).foreground,
					})

					-- Open floating window
					local title_text = title or "Message" -- fallback if empty
					local win = vim.api.nvim_open_win(buf, true, {
						relative = "editor",
						row = row,
						col = col,
						width = width,
						height = height,
						border = "rounded",
						title = " " .. icon .. (title_text ~= "" and " " .. title_text or "") .. " ",
						title_pos = "center",
					})
					vim.api.nvim_win_set_option(
						win,
						"winhl",
						table.concat({
							"FloatBorder:" .. border_hl,
							"NormalFloat:SnacksNotifier" .. Level,
							"FloatTitle:SnacksNotifierTitle" .. Level,
						}, ",")
					)
					-- Disable line numbers
					vim.api.nvim_win_set_option(win, "number", false)
					vim.api.nvim_win_set_option(win, "relativenumber", false)
					vim.api.nvim_win_set_option(win, "cursorline", false)
					vim.api.nvim_win_set_option(win, "cursorcolumn", false)
					vim.api.nvim_win_set_option(win, "statuscolumn", "")
					vim.api.nvim_win_set_option(win, "signcolumn", "no")
					vim.api.nvim_win_set_option(win, "foldcolumn", "0")
				end)

				return true
			end,
			previewer = previewers.new_buffer_previewer({
				define_preview = function(self, entry, status)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(entry.value.msg or "", "\n"))
					vim.bo[self.state.bufnr].filetype = "markdown"
				end,
			}),
		})
		:find()
end

vim.keymap.set("n", "<leader>fn", snacks_notifications, { desc = "Snacks Notifications (Telescope)" })

-- Oil
vim.keymap.set("n", "<leader>x", ":Oil<CR>")

-- Format with null-ls
vim.keymap.set("n", "<leader>cf", function()
	vim.lsp.buf.format({ async = true })
end, { noremap = true, silent = true, desc = "Format file with null-ls" })

-- lsp
-- NOTE: Load Telescope ui select extension for code actions in telescope
require("telescope").load_extension("ui-select")
local telescope = require("telescope.builtin")

-- Goto (under <leader>g for "goto")
vim.keymap.set("n", "<leader>gd", telescope.lsp_definitions, { desc = "Goto Definition" })
vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
vim.keymap.set("n", "<leader>gr", telescope.lsp_references, { desc = "Goto References" })
vim.keymap.set("n", "<leader>gi", telescope.lsp_implementations, { desc = "Goto Implementation" })
vim.keymap.set("n", "<leader>gt", telescope.lsp_type_definitions, { desc = "Goto Type Definition" })

-- Hover / Info
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, { desc = "Signature Help" })
vim.keymap.set("n", "<Esc>", "<cmd>fclose<CR>", { desc = "Close LSP hover window", remap = false })
-- BIG Hover window (60% screen)
local function big_hover()
	local params = vim.lsp.util.make_position_params()

	vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result, ctx, config)
		if err or not result or not result.contents then
			vim.notify("No hover information", vim.log.levels.INFO)
			return
		end

		-- Create a scratch buffer for the hover text
		local buf = vim.api.nvim_create_buf(false, true)
		local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
		-- markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, markdown_lines)
		vim.bo[buf].filetype = "markdown"
		vim.api.nvim_buf_set_option(buf, "buftype", "acwrite")
		vim.api.nvim_buf_set_option(buf, "buflisted", false)
		vim.api.nvim_buf_set_option(buf, "swapfile", false)
		vim.api.nvim_buf_set_option(buf, "modifiable", false)
		vim.api.nvim_buf_set_option(buf, "readonly", true)
		vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

		-- Tell Neovim: a markdown buffer was just created → trigger plugin hooks
		vim.api.nvim_exec_autocmds("FileType", { buffer = buf })

		-- Floating window size
		local width = math.floor(vim.o.columns * 0.75)
		local height = math.floor(vim.o.lines * 0.75)

		local col = math.floor((vim.o.columns - width) / 2)
		local row = math.floor((vim.o.lines - height) / 2)

		-- Floating window
		local win = vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			style = "minimal",
			border = "rounded",
			row = row,
			col = col,
			width = width,
			height = height,
		})
		vim.cmd("Markview HybridDisable")

		-- Use q or <Esc> to close
		-- mapping exists only for `buf` and is removed automatically when the buffer is deleted.
		vim.keymap.set("n", "<Esc>", function()
			-- close the window if still valid
			if vim.api.nvim_win_is_valid(win) then
				pcall(vim.api.nvim_win_close, win, true)
			end
			-- delete the buffer forcefully (equivalent to :bdel!)
			if vim.api.nvim_buf_is_loaded(buf) then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end, { buffer = buf, silent = true, noremap = true, desc = "Close & bdel! hover" })

		vim.keymap.set("n", "q", function()
			if vim.api.nvim_win_is_valid(win) then
				pcall(vim.api.nvim_win_close, win, true)
			end
			if vim.api.nvim_buf_is_loaded(buf) then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end, { buffer = buf, silent = true, noremap = true, desc = "Close & bdel! hover" })
		vim.keymap.set("n", "<C-w>c", function()
			if vim.api.nvim_win_is_valid(win) then
				pcall(vim.api.nvim_win_close, win, true)
			end
			if vim.api.nvim_buf_is_loaded(buf) then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end, { buffer = buf, silent = true, noremap = true, desc = "Close & bdel! hover" })
	end)
end

-- Keymap (no conflicts)
vim.keymap.set("n", "<leader>gk", big_hover, {
	desc = "Large Hover (scroll/search)",
})

-- Refactor
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

-- Diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.setloclist, { desc = "Diagnostics List" })

-- Workspace management
vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add Workspace Folder" })
vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove Workspace Folder" })
vim.keymap.set("n", "<leader>wl", function()
	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = "List Workspace Folders" })

-- Markview deactivate
vim.keymap.set("n", "<leader>m", ":Markview<CR>", { desc = "Toggle Markview" })

-- Obsidian mappings
vim.keymap.set("n", "<leader>of", ":Obsidian quick_switch<CR>", { desc = "Pick Obsidian notes" })
vim.keymap.set("n", "<leader>os", ":Obsidian search<CR>", { desc = "Search through Obsidian notes" })
vim.keymap.set("n", "<leader>on", ":Obsidian new<CR>", { desc = "Create note" })
vim.keymap.set("n", "<leader>oT", ":Obsidian new_from_template<CR>", { desc = "Create note from template" })
vim.keymap.set("n", "<leader>ot", ":Obsidian tags<CR><Esc>", { desc = "Search Obsidian tags" })
vim.keymap.set("n", "<leader>ob", ":Obsidian backlinks<CR><Esc>", { desc = "Search Obsidian backlinks" })

-- open Obsidian dailies, put picker in normal mode and go to today
vim.keymap.set("n", "<leader>od", function()
	vim.cmd("Obsidian dailies 1 -30")

	-- delay long enough for picker to fully initialize
	vim.defer_fn(function()
		vim.api.nvim_input("<Esc>")
		vim.api.nvim_input("k")
	end, 20) -- adjust if picker loads slow
end, { desc = "Search journal" })

-- lazygit mapping
vim.keymap.set("n", "<leader>gl", ":lua require('snacks').lazygit()<CR>", { desc = "Lazygit" })

-- undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Open undotree" })

local harpoon = require("harpoon")
harpoon:setup()
-- harpoon
vim.keymap.set("n", "<leader>ha", function()
	harpoon:list():add()
end, { desc = "Add to harpoon" })
vim.keymap.set("n", "<leader>hd", function()
	harpoon:list():remove()
end, { desc = "Remove from harpoon" })
vim.keymap.set("n", "<leader>hl", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "List harpoon buffers" })
vim.keymap.set("n", "<leader>hc", function()
	harpoon:list():clear()
end, { desc = "Clear harpoon buffers" })

vim.keymap.set("n", "<M-h>", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<M-j>", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<M-k>", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<M-l>", function()
	harpoon:list():select(4)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<C-S-N>", function()
	harpoon:list():next()
end)

-- TODO comments
vim.keymap.set("n", "<leader>ftd", ":TodoTelescope <CR>")
vim.keymap.set("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- You can also specify a list of valid jump keywords

-- HACK: Manage Markdown tasks in Neovim similar to Obsidian | Create weekly task management notes with
-- automatic links to daily journals of all days in the week
-- Inspired by Linkarzu on Youtube
--
-- ObsidianNewFromTemplate can be used with the template substitution option but this is easier
--
-- The keymap calls ObsidianNew to create a new file, deletes from line 5 to end of the buffer to remove
-- automatic level one heading and empty tags field. Then links are added under ## Dailies and the cursor
-- moves after line 4 to call ObsidianTemplate to choose the template.
vim.keymap.set("n", "<leader>tdw", function()
	local year = os.date("%Y")
	local week = os.date("%V") -- ISO week number

	-- Build directory and filename
	local dir = "tasks/" .. year
	local filename = dir .. "/" .. week
	local template = "tasks"

	-- Ensure the directory exists
	vim.fn.mkdir(dir, "p")

	-- Create the new note
	vim.cmd("Obsidian new " .. filename)

	-- Schedule buffer operations after file is created
	vim.schedule(function()
		local bufnr = vim.api.nvim_get_current_buf()

		-- Delete from line 4 to end of buffer (Lua index is 0-based)
		local line_count = vim.api.nvim_buf_line_count(bufnr)
		if line_count >= 4 then
			vim.api.nvim_buf_set_lines(bufnr, 3, line_count, false, {})
		end

		-- --- Build daily links for the week ---
		local function iso_week_monday(currentYear, currentWeek)
			-- January 4th is always in week 1
			local jan4 = os.time({ year = currentYear, month = 1, day = 4 })
			local jan4_wday = tonumber(os.date("%w", jan4))
			-- Compute offset to Monday (ISO: Monday=1, Sunday=7)
			local offset = (jan4_wday == 0 and -6 or 1 - jan4_wday)
			local first_monday = jan4 + offset * 24 * 60 * 60
			return first_monday + (currentWeek - 1) * 7 * 24 * 60 * 60
		end

		local week_monday = iso_week_monday(tonumber(year), tonumber(week))
		local links = {}
		for i = 0, 6 do
			local day_time = week_monday + i * 24 * 60 * 60
			local day_link = os.date("%Y-%m-%d", day_time)
			local day_display = os.date("%A - %d %b, %Y", day_time)
			table.insert(links, string.format("- [[%s|%s]]", day_link, day_display))
		end

		-- Append links under ## Dailies
 		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "", "## Dailies" })
 		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, links)
 		-- === NEW PART: replace the last word of line 3 with "Week <week number>,<year>" ===
 		local line_nr = 2 -- Lua index 0-based, line 3 is index 2
 		local line = vim.api.nvim_buf_get_lines(bufnr, line_nr, line_nr + 1, false)[1]
 		if line then
 			local new_line = line:gsub("(%S+)$", "Week " .. week .. "," .. year) -- replace last word
 			vim.api.nvim_buf_set_lines(bufnr, line_nr, line_nr + 1, false, { new_line })
 			-- optional: move cursor to end of the line
 			vim.api.nvim_win_set_cursor(0, { line_nr + 1, #new_line })
 		end
		-- Move cursor to new line after line 4 (where template will be inserted)
		vim.api.nvim_win_set_cursor(0, { 5, 0 })

		-- Trigger template picker
		vim.cmd("Obsidian template " .. template)
		vim.lsp.buf.format({ async = true })
		vim.api.nvim_win_set_cursor(0, { 13, 0 })
	end)
end, { desc = "New weekly tasks note with daily links and template" })

-- Same but for next week
--
vim.keymap.set("n", "<leader>tdn", function()
	-- Get today
	local today = os.time()
	-- Get next Monday
	local next_monday = today + ((8 - tonumber(os.date("%w", today))) % 7) * 24 * 60 * 60
	-- ISO year and week of next Monday
	local year = os.date("%G", next_monday) -- ISO year
	local week = os.date("%V", next_monday) -- ISO week number

	-- Build directory and filename
	local dir = "tasks/" .. year
	local filename = dir .. "/" .. week
	local template = "tasks"

	-- Ensure the directory exists
	vim.fn.mkdir(dir, "p")

	-- Create the new note
	vim.cmd("Obsidian new " .. filename)

	-- Schedule buffer operations after file is created
	vim.schedule(function()
		local bufnr = vim.api.nvim_get_current_buf()

		-- Delete from line 4 to end of buffer (Lua index is 0-based)
		local line_count = vim.api.nvim_buf_line_count(bufnr)
		if line_count >= 4 then
			vim.api.nvim_buf_set_lines(bufnr, 3, line_count, false, {})
		end

		-- --- Build daily links for the week ---
		local function iso_week_monday(currentYear, currentWeek)
			-- January 4th is always in week 1
			local jan4 = os.time({ year = currentYear, month = 1, day = 4 })
			local jan4_wday = tonumber(os.date("%w", jan4))
			-- Compute offset to Monday (ISO: Monday=1, Sunday=7)
			local offset = (jan4_wday == 0 and -6 or 1 - jan4_wday)
			local first_monday = jan4 + offset * 24 * 60 * 60
			return first_monday + (currentWeek - 1) * 7 * 24 * 60 * 60
		end

		local week_monday = iso_week_monday(tonumber(year), tonumber(week))
		local links = {}
		for i = 0, 6 do
			local day_time = week_monday + i * 24 * 60 * 60
			local day_link = os.date("%Y-%m-%d", day_time)
			local day_display = os.date("%A - %d %b, %Y", day_time)
			table.insert(links, string.format("- [[%s|%s]]", day_link, day_display))
		end

		-- Append links under ## Dailies
		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "", "## Dailies" })
		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, links)

 		-- === NEW PART: replace the last word of line 3 with "Week <week number>,<year>" ===
 		local line_nr = 2 -- Lua index 0-based, line 3 is index 2
 		local line = vim.api.nvim_buf_get_lines(bufnr, line_nr, line_nr + 1, false)[1]
 		if line then
 			local new_line = line:gsub("(%S+)$", "Week " .. week .. "," .. year) -- replace last word
 			vim.api.nvim_buf_set_lines(bufnr, line_nr, line_nr + 1, false, { new_line })
 			-- optional: move cursor to end of the line
 			vim.api.nvim_win_set_cursor(0, { line_nr + 1, #new_line })
 		end
		-- Move cursor to new line after line 4 (where template will be inserted)
		vim.api.nvim_win_set_cursor(0, { 5, 0 })

		-- Trigger template picker
		vim.cmd("Obsidian template " .. template)
		vim.lsp.buf.format({ async = true })
		vim.api.nvim_win_set_cursor(0, { 13, 0 })
	end)
end, { desc = "New weekly tasks note for next week" })

-- HACK: Manage Markdown tasks in Neovim similar to Obsidian | Telescope to List Completed and Pending Tasks
-- https://youtu.be/59hvZl077hM
--
-- https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/keymaps.lua
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local themes = require("telescope.themes")

-- Iterate through completed tasks in telescope lamw25wmal
local Job = require("plenary.job")

vim.keymap.set("n", "<leader>tdc", function()
	local search_dirs = { vim.fn.expand("$HOME/Notes/tasks/") }
	local rg_args = { "--no-ignore", "-n", "-H", "-e", "^\\s*- \\[x\\] `done:" }

	local results = {}
	require("plenary.job")
		:new({
			command = "rg",
			args = vim.list_extend(rg_args, search_dirs),
			on_stdout = function(_, line)
				local filepath, lnum, text = line:match("(.+):(%d+):(.+)")
				if filepath and lnum and text then
					local week = filepath:match("tasks/%d+/(%d+)")
					-- Extract date and task
					local date, task = text:match("^%s*%- %[x%]%s*`done:%s*([^`]+)`%s*(.*)")
					task = task:gsub("%s*%[%[(https?://.-)%]%]$", "") -- Remove trailing reference links
					local display_text = string.format("%s — %s", date, task)
					table.insert(
						results,
						{ week = week or "?", lnum = lnum, text = display_text, path = filepath, raw = text }
					)
				end
			end,
		})
		:sync()

	local opts = themes.get_dropdown({
		prompt_title = "Completed Tasks",
		initial_mode = "normal",
		previewer = false,
	})

	-- Simple reverse alphanumeric sort
	table.sort(results, function(a, b)
		return a.week > b.week
	end)

	pickers
		.new(opts, {
			finder = finders.new_table({
				results = results,
				entry_maker = function(entry)
					return {
						value = entry,
						display = string.format("Week %s -> %s", entry.week, entry.text),
						ordinal = entry.text,
						path = entry.path,
						lnum = entry.lnum,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					vim.cmd(string.format("edit +%d %s", selection.lnum, vim.fn.fnameescape(selection.path)))
				end)
				return true
			end,
		})
		:find()
end, { desc = "Search for completed tasks with week number" })

-- -- Iterate through incomplete tasks in telescope
-- -- You can confirm in your teminal lamw25wmal with:
-- -- rg "^\s*-\s\[ \]" test-markdown.md
vim.keymap.set("n", "<leader>tdt", function()
	local search_dirs = { vim.fn.expand("$HOME/Notes/tasks/") }
	local rg_args = { "--no-ignore", "-n", "-H", "-e", "^\\s*- \\[ \\]" }
	local results = {}

	Job:new({
		command = "rg",
		args = vim.list_extend(rg_args, search_dirs),
		on_stdout = function(_, line)
			-- line format: /path/to/file:linenumber:matched_line
			local filepath, lnum, text = line:match("(.+):(%d+):(.+)")
			if filepath and lnum and text then
				local week = filepath:match("tasks/%d+/(%d+)")
				local display_text = text:gsub("^%s*- %[%s%]%s*", "")
				display_text = display_text:gsub("%s*%[%[(https?://.-)%]%]$", "") -- Remove trailing reference links
				table.insert(results, {
					week = tonumber(week) or 0, -- convert to number for sorting
					lnum = tonumber(lnum),
					text = display_text,
					path = filepath,
				})
			end
		end,
	}):sync()

	local opts = themes.get_dropdown({
		prompt_title = "Incomplete Tasks",
		initial_mode = "normal",
		previewer = false, -- Disable preview
	})

	-- Sort ascending by week number
	table.sort(results, function(a, b)
		return a.week < b.week
	end)

	pickers
		.new(opts, {
			prompt_title = "Incomplete Tasks",
			finder = finders.new_table({
				results = results,
				entry_maker = function(entry)
					return {
						value = entry,
						display = string.format("Week %02d -> %s", entry.week, entry.text),
						ordinal = entry.text,
						path = entry.path,
						lnum = entry.lnum,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			initial_mode = "normal",
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					vim.cmd(string.format("edit +%d %s", selection.lnum, vim.fn.fnameescape(selection.path)))
				end)
				return true
			end,
		})
		:find()
end, { desc = "Search for incomplete tasks with week numbers" })

-- <leader>tdf : pick weekly task files under ~/Notes/tasks/<year>/<week>-randomtag.md
local scan = require("plenary.scandir")

vim.keymap.set("n", "<leader>tdf", function()
	local root = vim.fn.expand("~/Notes/tasks")

	-- Recursively collect *.md files (depth=2: year dir + files inside)
	local paths = scan.scan_dir(root, {
		hidden = false,
		add_dirs = false,
		depth = 2,
		respect_gitignore = false,
	})

	-- Keep only markdown files
	local results = {}
	for _, p in ipairs(paths) do
		if p:sub(-3) == ".md" then
			table.insert(results, p)
		end
	end

	if #results == 0 then
		vim.notify("No weekly task files found under " .. root, vim.log.levels.INFO)
		return
	end

	-- Simple reverse alphanumeric sort
	table.sort(results, function(a, b)
		return a > b
	end)

	pickers
		.new(themes.get_dropdown({ previewer = false }), {
			prompt_title = "Weekly Task Files",
			finder = finders.new_table({
				results = results,
				entry_maker = function(entry)
					-- entry like: /home/sundar/Notes/tasks/2025/33-1755354343.md
					local basename = vim.fn.fnamemodify(entry, ":t") -- 33-1755354343.md
					local year = entry:match("/tasks/(%d%d%d%d)/") or "????"
					local week = (basename:match("^(%d+)%-.+")) or basename:gsub("%.md$", "")
					return {
						value = entry,
						display = string.format("%s – Week %s", year, week),
						ordinal = table.concat({ year, week, basename }, " "),
						path = entry,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.file_previewer({}), -- uses `bat` automatically if available
			initial_mode = "normal",
			attach_mappings = function(_, map)
				local function open_file(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					vim.cmd.edit(selection.value)
				end
				map("i", "<CR>", open_file)
				map("n", "<CR>", open_file)
				return true
			end,
		})
		:find()
end, { desc = "Search weekly task files" })
-- Commented these 2 as I couldn't clear search results with escape
-- I want to close split panes with escape, the default is "q"
-- vim.keymap.set("n", "<esc>", "<cmd>close<cr>", { desc = "Close split pane" })
-- I also want to close split panes with escape in terminal mode
-- vim.keymap.set("n", "<esc>", "<C-W>c", { desc = "Delete Window", remap = true })

-- HACK: Manage Markdown tasks in Neovim similar to Obsidian | Telescope to List Completed and Pending Tasks
-- https://youtu.be/59hvZl077hM
--
-- If there is no `untoggled` or `done` label on an item, mark it as done
-- and move it to the "## completed tasks" markdown heading in the same file, if
-- the heading does not exist, it will be created, if it exists, items will be
-- appended to it at the top lamw25wmal
--
-- If an item is moved to that heading, it will be added the `done` label
vim.keymap.set("n", "<M-x>", function()
	-- Customizable variables
	-- NOTE: Customize the completion label
	local label_done = "done:"
	-- NOTE: Customize the timestamp format
	local timestamp = os.date("%d %b, %y - %H:%M")
	-- local timestamp = os.date("%y%m%d")
	-- NOTE: Customize the heading and its level
	local tasks_heading = "## Completed"
	-- Save the view to preserve folds
	vim.cmd("mkview")
	local api = vim.api
	-- Retrieve buffer & lines
	local buf = api.nvim_get_current_buf()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local start_line = cursor_pos[1] - 1
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local total_lines = #lines
	-- If cursor is beyond last line, do nothing
	if start_line >= total_lines then
		vim.cmd("loadview")
		return
	end
	------------------------------------------------------------------------------
	-- (A) Move upwards to find the bullet line (if user is somewhere in the chunk)
	------------------------------------------------------------------------------
	while start_line > 0 do
		local line_text = lines[start_line + 1]
		-- Stop if we find a blank line or a bullet line
		if line_text == "" or line_text:match("^%s*%-") then
			break
		end
		start_line = start_line - 1
	end
	-- Now we might be on a blank line or a bullet line
	if lines[start_line + 1] == "" and start_line < (total_lines - 1) then
		start_line = start_line + 1
	end
	------------------------------------------------------------------------------
	-- (B) Validate that it's actually a task bullet, i.e. '- [ ]' or '- [x]'
	------------------------------------------------------------------------------
	local bullet_line = lines[start_line + 1]
	if not bullet_line:match("^%s*%- %[[x ]%]") then
		-- Not a task bullet => show a message and return
		print("Not a task bullet: no action taken.")
		vim.cmd("loadview")
		return
	end
	------------------------------------------------------------------------------
	-- 1. Identify the chunk boundaries
	------------------------------------------------------------------------------
	local chunk_start = start_line
	local chunk_end = start_line
	while chunk_end + 1 < total_lines do
		local next_line = lines[chunk_end + 2]
		if next_line == "" or next_line:match("^%s*%-") then
			break
		end
		chunk_end = chunk_end + 1
	end
	-- Collect the chunk lines
	local chunk = {}
	for i = chunk_start, chunk_end do
		table.insert(chunk, lines[i + 1])
	end
	------------------------------------------------------------------------------
	-- 2. Check if chunk has [done: ...] or [untoggled], then transform them
	------------------------------------------------------------------------------
	local has_done_index = nil
	local has_untoggled_index = nil
	for i, line in ipairs(chunk) do
		-- Replace `[done: ...]` -> `` `done: ...` ``
		chunk[i] = line:gsub("%[done:([^%]]+)%]", "`" .. label_done .. "%1`")
		-- Replace `[untoggled]` -> `` `untoggled` ``
		chunk[i] = chunk[i]:gsub("%[untoggled%]", "`untoggled`")
		if chunk[i]:match("`" .. label_done .. ".-`") then
			has_done_index = i
			break
		end
	end
	if not has_done_index then
		for i, line in ipairs(chunk) do
			if line:match("`untoggled`") then
				has_untoggled_index = i
				break
			end
		end
	end
	------------------------------------------------------------------------------
	-- 3. Helpers to toggle bullet
	------------------------------------------------------------------------------
	-- Convert '- [ ]' to '- [x]'
	local function bulletToX(line)
		return line:gsub("^(%s*%- )%[%s*%]", "%1[x]")
	end
	-- Convert '- [x]' to '- [ ]'
	local function bulletToBlank(line)
		return line:gsub("^(%s*%- )%[x%]", "%1[ ]")
	end
	------------------------------------------------------------------------------
	-- 4. Insert or remove label *after* the bracket
	------------------------------------------------------------------------------
	local function insertLabelAfterBracket(line, label)
		local prefix = line:match("^(%s*%- %[[x ]%])")
		if not prefix then
			return line
		end
		local rest = line:sub(#prefix + 1)
		return prefix .. " " .. label .. rest
	end
	local function removeLabel(line)
		-- If there's a label (like `` `done: ...` `` or `` `untoggled` ``) right after
		-- '- [x]' or '- [ ]', remove it
		return line:gsub("^(%s*%- %[[x ]%])%s+`.-`", "%1")
	end
	------------------------------------------------------------------------------
	-- 5. Update the buffer with new chunk lines (in place)
	------------------------------------------------------------------------------
	local function updateBufferWithChunk(new_chunk)
		for idx = chunk_start, chunk_end do
			lines[idx + 1] = new_chunk[idx - chunk_start + 1]
		end
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	end
	------------------------------------------------------------------------------
	-- 6. Main toggle logic
	------------------------------------------------------------------------------
	if has_done_index then
		chunk[has_done_index] = removeLabel(chunk[has_done_index]):gsub("`" .. label_done .. ".-`", "`untoggled`")
		chunk[1] = bulletToBlank(chunk[1])
		chunk[1] = removeLabel(chunk[1])
		chunk[1] = insertLabelAfterBracket(chunk[1], "`untoggled`")
		updateBufferWithChunk(chunk)
		vim.notify("Untoggled", vim.log.levels.INFO)
	elseif has_untoggled_index then
		chunk[has_untoggled_index] =
			removeLabel(chunk[has_untoggled_index]):gsub("`untoggled`", "`" .. label_done .. " " .. timestamp .. "`")
		chunk[1] = bulletToX(chunk[1])
		chunk[1] = removeLabel(chunk[1])
		chunk[1] = insertLabelAfterBracket(chunk[1], "`" .. label_done .. " " .. timestamp .. "`")
		updateBufferWithChunk(chunk)
		vim.notify("Completed", vim.log.levels.INFO)
	else
		-- Save original window view before modifications
		local win = api.nvim_get_current_win()
		local view = api.nvim_win_call(win, function()
			return vim.fn.winsaveview()
		end)
		chunk[1] = bulletToX(chunk[1])
		chunk[1] = insertLabelAfterBracket(chunk[1], "`" .. label_done .. " " .. timestamp .. "`")
		-- Remove chunk from the original lines
		for i = chunk_end, chunk_start, -1 do
			table.remove(lines, i + 1)
		end
		-- Append chunk under 'tasks_heading'
		local heading_index = nil
		for i, line in ipairs(lines) do
			if line:match("^" .. tasks_heading) then
				heading_index = i
				break
			end
		end
		if heading_index then
			for _, cLine in ipairs(chunk) do
				table.insert(lines, heading_index + 1, cLine)
				heading_index = heading_index + 1
			end
			-- Remove any blank line right after newly inserted chunk
			local after_last_item = heading_index + 1
			if lines[after_last_item] == "" then
				table.remove(lines, after_last_item)
			end
		else
			table.insert(lines, tasks_heading)
			for _, cLine in ipairs(chunk) do
				table.insert(lines, cLine)
			end
			local after_last_item = #lines + 1
			if lines[after_last_item] == "" then
				table.remove(lines, after_last_item)
			end
		end
		-- Update buffer content
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.notify("Completed", vim.log.levels.INFO)
		-- Restore window view to preserve scroll position
		api.nvim_win_call(win, function()
			vim.fn.winrestview(view)
		end)
	end
	-- Write changes and restore view to preserve folds
	-- "Update" saves only if the buffer has been modified since the last save
	vim.cmd("silent update")
	vim.cmd("loadview")
	vim.lsp.buf.format({ async = true })
end, { desc = "[P]Toggle task and move it to 'done'" })

-- -- Toggle bullet point at the beginning of the current line in normal mode
-- vim.keymap.set("n", "<leader>ml", function()
--   -- Notify that the function is being executed
--   vim.notify("Executing bullet point toggle function", vim.log.levels.INFO)
--   -- Get the current cursor position
--   local cursor_pos = vim.api.nvim_win_get_cursor(0)
--   vim.notify("Cursor position: row " .. cursor_pos[1] .. ", col " .. cursor_pos[2], vim.log.levels.INFO)
--   local current_buffer = vim.api.nvim_get_current_buf()
--   local row = cursor_pos[1] - 1
--   -- Get the current line
--   local line = vim.api.nvim_buf_get_lines(current_buffer, row, row + 1, false)[1]
--   vim.notify("Current line: " .. line, vim.log.levels.INFO)
--   if line:match("^%s*%-") then
--     -- If the line already starts with a bullet point, remove it
--     vim.notify("Bullet point detected, removing it", vim.log.levels.INFO)
--     line = line:gsub("^%s*%-", "", 1)
--     vim.api.nvim_buf_set_lines(current_buffer, row, row + 1, false, { line })
--   else
--     -- Otherwise, delete the line, add a bullet point, and paste the text
--     vim.notify("No bullet point detected, adding it", vim.log.levels.INFO)
--     line = "- " .. line
--     vim.api.nvim_buf_set_lines(current_buffer, row, row + 1, false, { line })
--   end
-- end, { desc = "Toggle bullet point at the beginning of the current line" })

-- Toggle LSP inlay hints (Neovim ≥0.10)
vim.keymap.set("n", "<leader>ci", function()
	local bufnr = 0 -- 0 = current buffer
	local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
	vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
end, { desc = "Toggle Inlay Hints" })

-- Typst preview
vim.keymap.set("n", "<leader>tp", ":TypstPreview<CR>", { desc = "Typst Preview" })
