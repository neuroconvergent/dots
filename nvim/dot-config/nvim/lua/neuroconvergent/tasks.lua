local scan = require("plenary.scandir")

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

local function search_task_files()
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
			local basename = vim.fn.fnamemodify(p, ":t")
			local year = p:match("/tasks/(%d%d%d%d)/") or "????"
			local week = (basename:match("^(%d+)%-.+")) or basename:gsub("%.md$", "")

			local week_monday = iso_week_monday(year, week)
			local day_text = ""

			for i = 0, 6 do
				local day_time = week_monday + i * 24 * 60 * 60
				local day_display = os.date("%d %b", day_time)
                if i>0 then
                    day_text = string.format("%s, %s", day_text, day_display)
                else
                    day_text = string.format(" %s", day_display)
                end
			end

			table.insert(results, {
				path = p,
				year = year,
				week = week,
				day_text = day_text,
				text = string.format("%s – Week %s - %s", year, week, day_text),
				file = p,
			})
		end
	end

	if #results == 0 then
		vim.notify("No weekly task files found under " .. root, vim.log.levels.INFO)
		return
	end

	-- Simple reverse alphanumeric sort
	table.sort(results, function(a, b)
		return a.path > b.path
	end)

	Snacks.picker.pick({
		title = "Weekly Task Files",
		layout = { preset = "ivy", preview = false },
		focus = "input",
		items = results,
		preview = "file",
		-- Apply the same logic as your other pickers
		format = function(item, _)
			local ret = {}
			table.insert(ret, { "󰃭 ", "SnacksPickerIconDate" })
			table.insert(ret, { "Week " .. item.week .. ", " .. item.year, "Keyword" }) -- "Keyword" gives it a different color
			table.insert(ret, { item.day_text, "Comment" })
			return ret
		end,
		confirm = function(picker, item)
			if not item then
				return
			end
			picker:close()
			vim.cmd.edit(item.path)
		end,
	})
end

local function toggle_task()
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
end

local function create_weekly()
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
			local new_line = line:gsub("(%S+)$", "aliases: Week " .. week .. ", " .. year) -- replace last word
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
end

local function create_weekly_next()
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
			local new_line = line:gsub("(%S+)$", "aliases: Week " .. week .. ", " .. year) -- replace last word
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
end

local function find_tasks_completed()
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
					local year = filepath:match("tasks/(%d+)/%d+")
					-- Extract date and task
					local date, task = text:match("^%s*%- %[x%]%s*`done:%s*([^`]+)`%s*(.*)")
					if date and task then
						task = task:gsub("%s*%[%[(https?://.-)%]%]$", "")
						table.insert(results, {
							year = year or "????",
							week = tonumber(week) or 0,
							lnum = tonumber(lnum),
							path = filepath,
							-- Store parts separately for the formatter
							date_str = date,
							task_str = task,
							-- 'text' is still used for internal filtering/searching
							text = date .. " " .. task,
						})
					end
				end
			end,
		})
		:sync()

	table.sort(results, function(a, b)
		return a.week > b.week
	end)

	Snacks.picker.pick({
		title = "Completed Tasks",
		layout = { preset = "ivy", preview = false },
		items = results,
		format = function(item, _)
			local ret = {}
			-- 1. Format the Date (using a comment or constant highlight)
			table.insert(ret, { "󰃭 ", "SnacksPickerIconDate" }) -- Optional icon
			local meta = string.format("%s - Week %02d", item.year, item.week)
			table.insert(ret, { meta, "Special" }) -- Pink/Orange in most themes
			table.insert(ret, { "  ", "NonText" })
			table.insert(ret, { item.date_str, "Keyword" })

			-- 2. Add a separator
			table.insert(ret, { " — ", "NonText" })

			-- 3. Format the Task text
			table.insert(ret, { item.task_str, "Normal" })

			return ret
		end,
		confirm = function(picker, item)
			if not item then
				return
			end
			picker:close()
			vim.cmd(string.format("edit +%d %s", item.lnum, vim.fn.fnameescape(item.path)))
		end,
	})
end

local function find_tasks_incomplete()
	local search_dirs = { vim.fn.expand("$HOME/Notes/tasks/") }
	local rg_args = { "--no-ignore", "-n", "-H", "-e", "^\\s*- \\[ \\]" }
	local results = {}

	require("plenary.job")
		:new({
			command = "rg",
			args = vim.list_extend(rg_args, search_dirs),
			on_stdout = function(_, line)
				local filepath, lnum, text = line:match("(.+):(%d+):(.+)")
				if filepath and lnum and text then
					local year = filepath:match("tasks/(%d+)/%d+")
					local week = filepath:match("tasks/%d+/(%d+)")

					-- Clean up the task text
					local task = text:gsub("^%s*- %[%s%]%s*", "")
					task = task:gsub("%s*%[%[(https?://.-)%]%]$", "")

					table.insert(results, {
						year = year or "????",
						week = tonumber(week) or 0,
						lnum = tonumber(lnum),
						task_text = task, -- Store clean task separately
						path = filepath,
						-- 'text' is used by the picker for internal fuzzy searching
						text = string.format("%s Week %s %s", year or "", week or "", task),
					})
				end
			end,
		})
		:sync()

	table.sort(results, function(a, b)
		return a.week < b.week
	end)

	Snacks.picker.pick({
		title = "Incomplete Tasks",
		layout = { preset = "ivy", preview = false },
		items = results,
		-- Custom formatter to apply highlights
		format = function(item, _)
			local ret = {}

			-- 1. Format the Year and Week as 'Special' (usually colorful)
			table.insert(ret, { "󰃭 ", "SnacksPickerIconDate" })
			local meta = string.format("%s - Week %02d", item.year, item.week)
			table.insert(ret, { meta, "Special" })

			-- 2. Add a subtle separator
			table.insert(ret, { "  ", "NonText" })

			-- 3. Add the actual task text in the default color
			table.insert(ret, { item.task_text, "Normal" })

			return ret
		end,
		confirm = function(picker, item)
			if not item then
				return
			end
			picker:close()
			vim.cmd(string.format("edit +%d %s", item.lnum, vim.fn.fnameescape(item.path)))
		end,
	})
end

return {
	search_task_files = search_task_files,
	toggle_task = toggle_task,
	create_weekly = create_weekly,
	create_weekly_next = create_weekly_next,
	find_tasks_completed = find_tasks_completed,
	find_tasks_incomplete = find_tasks_incomplete,
}
