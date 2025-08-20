-- Tab manipulation
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>")
vim.keymap.set("n", "<M-w>", ":bdel<CR>")
vim.keymap.set("n", "<M-t>", ":enew<CR>")

-- Clear search highlighting
vim.keymap.set("n", "<C-f>", ':let @/ = "" <CR>')

-- Warped line motion
vim.keymap.set("n", "<C-j>", "gj")
vim.keymap.set("n", "<C-k>", "gk")

vim.g.mapleader = " "
vim.g.maplocalleade = "\\"

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", ":Telescope find_files hidden=true <CR>", default_opts) -- Find Files
vim.keymap.set("n", "<leader>fr", ":Telescope oldfiles hidden=true <CR>", default_opts)
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", default_opts)
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", default_opts)
vim.keymap.set("n", "<leader>fn", ":Telescope notify<CR>", default_opts)
vim.keymap.set("n", "<leader>fgc", ":Telescope git_bcommits<CR>", default_opts)
vim.keymap.set("n", "<leader>fgs", ":Telescope git_status<CR>", default_opts)
vim.keymap.set("n", "<leader>fss", ":Telescope grep_string<CR>", default_opts)
vim.keymap.set("n", "<leader>fsg", ":Telescope live_grep<CR>", default_opts)

-- Oil
vim.keymap.set("n", "<leader>x", ":Oil<CR>")

-- Conform
vim.api.nvim_set_keymap(
	"n",
	"<leader>cf",
	"<cmd>lua require('conform').format()<CR>",
	{ noremap = true, silent = true }
)

-- Diagnostics
vim.keymap.set("n", "<leader>cd", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Markview deactivate
vim.keymap.set("n", "<leader>m", ":Markview<CR>", default_opts)

-- Obsidian mappings
vim.keymap.set("n", "<leader>of", ":ObsidianQuickSwitch<CR>", default_opts)
vim.keymap.set("n", "<leader>on", ":ObsidianNew<CR>", default_opts)
vim.keymap.set("n", "<leader>ot", ":ObsidianNewFromTemplate<CR>", default_opts)
vim.keymap.set("n", "<leader>od", ":ObsidianDailies<CR>", default_opts)

-- lazygit mapping
vim.keymap.set("n", "<leader>gl", ":lua require('snacks').lazygit()<CR>", default_opts)

-- undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

local harpoon = require("harpoon")
harpoon:setup()
-- harpoon
vim.keymap.set("n", "<leader>ha", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<leader>hd", function()
	harpoon:list():remove()
end)
vim.keymap.set("n", "<leader>hl", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<M-1>", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<M-2>", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<M-3>", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<M-4>", function()
	harpoon:list():select(4)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<C-S-N>", function()
	harpoon:list():next()
end)

-- HACK: Manage Markdown tasks in Neovim similar to Obsidian | Create weekly task management notes with
-- automatic links to daily journals of all days in the week
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
	vim.cmd("ObsidianNew " .. filename)

	-- Schedule buffer operations after file is created
	vim.schedule(function()
		local bufnr = vim.api.nvim_get_current_buf()

		-- Delete from line 5 to end of buffer (Lua index is 0-based)
		local line_count = vim.api.nvim_buf_line_count(bufnr)
		if line_count >= 5 then
			vim.api.nvim_buf_set_lines(bufnr, 4, line_count, false, {})
		end

		-- --- Build daily links for the week ---
		local function iso_week_monday(year, week)
			-- January 4th is always in week 1
			local jan4 = os.time({ year = year, month = 1, day = 4 })
			local jan4_wday = tonumber(os.date("%w", jan4))
			-- Compute offset to Monday (ISO: Monday=1, Sunday=7)
			local offset = (jan4_wday == 0 and -6 or 1 - jan4_wday)
			local first_monday = jan4 + offset * 24 * 60 * 60
			return first_monday + (week - 1) * 7 * 24 * 60 * 60
		end

		local week_monday = iso_week_monday(tonumber(year), tonumber(week))
		local links = {}
		for i = 0, 6 do
			local day_time = week_monday + i * 24 * 60 * 60
			local day_link = os.date("%Y-%m-%d", day_time)
			local day_display = os.date("%A - %d %b, %Y", day_time)
			table.insert(links, string.format("[[%s|%s]]", day_link, day_display))
		end

		-- Append links under ## Dailies
		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "", "## Dailies" })
		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, links)

		-- Move cursor to new line after line 4 (where template will be inserted)
		vim.api.nvim_win_set_cursor(0, { 5, 0 })

		-- Trigger template picker
		vim.cmd("ObsidianTemplate " .. template)
		require("conform").format()
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
	local year = tonumber(os.date("%G", next_monday)) -- ISO year
	local week = tonumber(os.date("%V", next_monday)) -- ISO week number

	-- Build directory and filename
	local dir = "tasks/" .. year
	local filename = dir .. "/" .. week
	local template = "tasks"

	-- Ensure the directory exists
	vim.fn.mkdir(dir, "p")

	-- Create the new note
	vim.cmd("ObsidianNew " .. filename)

	-- Schedule buffer operations after file is created
	vim.schedule(function()
		local bufnr = vim.api.nvim_get_current_buf()

		-- Delete from line 5 to end of buffer (Lua index is 0-based)
		local line_count = vim.api.nvim_buf_line_count(bufnr)
		if line_count >= 5 then
			vim.api.nvim_buf_set_lines(bufnr, 4, line_count, false, {})
		end

		-- --- Build daily links for the week ---
		local function iso_week_monday(year, week)
			-- January 4th is always in week 1
			local jan4 = os.time({ year = year, month = 1, day = 4 })
			local jan4_wday = tonumber(os.date("%w", jan4))
			-- Compute offset to Monday (ISO: Monday=1, Sunday=7)
			local offset = (jan4_wday == 0 and -6 or 1 - jan4_wday)
			local first_monday = jan4 + offset * 24 * 60 * 60
			return first_monday + (week - 1) * 7 * 24 * 60 * 60
		end

		local week_monday = iso_week_monday(tonumber(year), tonumber(week))
		local links = {}
		for i = 0, 6 do
			local day_time = week_monday + i * 24 * 60 * 60
			local day_link = os.date("%Y-%m-%d", day_time)
			local day_display = os.date("%A - %d %b, %Y", day_time)
			table.insert(links, string.format("[[%s|%s]]", day_link, day_display))
		end

		-- Append links under ## Dailies
		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "", "## Dailies" })
		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, links)

		-- Move cursor to new line after line 4 (where template will be inserted)
		vim.api.nvim_win_set_cursor(0, { 5, 0 })

		-- Trigger template picker
		vim.cmd("ObsidianTemplate " .. template)
		require("conform").format()
	end)
end, { desc = "New weekly tasks note with daily links and template" })

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
		previewer = true,
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
end, { desc = "[P]Search for completed tasks with week number" })

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
end, { desc = "[P]Search for incomplete tasks with week numbers" })

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
		.new({}, {
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
end, { desc = "Pick weekly task files" })
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
	require("conform").format()
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
