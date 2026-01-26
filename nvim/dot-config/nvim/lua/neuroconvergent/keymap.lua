-- Import custom functions
local custom_func = require("neuroconvergent.custom_functions")
local tasks = require("neuroconvergent.tasks")

-- Terminal mode
vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { noremap = true, desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-q>", "<C-\\><C-n>", { noremap = true, desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", { noremap = true, desc = "Exit terminal mode and manipulate buffer" })

-- Remap scroll to centre window
-- vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- vim.keymap.set("n", "n", "nzzzv")
-- vim.keymap.set("n", "N", "Nzzzv")

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

-- vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

-- Snacks pickers
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files({ hidden = true })
end, { desc = "Find Files" }) -- Find Files
vim.keymap.set("n", "<leader>fr", function()
	Snacks.picker.recent()
end, { desc = "Find Recent Files" })
vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.zoxide()
end, { desc = "Find Projects" })
vim.keymap.set("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fh", function()
	Snacks.picker.help()
end, { desc = "Search Help Tags" })
vim.keymap.set("n", "<leader>fn", function()
	Snacks.picker.notifications()
end, { desc = "Search Notifications" })
vim.keymap.set("n", "<leader>fm", function()
	Snacks.picker.man()
end, { desc = "Search Manpages" })
vim.keymap.set("n", "<leader>fi", function()
	Snacks.picker.icons()
end, { desc = "Search Icons" })

-- search/grep
vim.keymap.set("n", "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "Search Word" })
vim.keymap.set("n", "<leader>sl", function()
	Snacks.picker.grep()
end, { desc = "Search Text" })
vim.keymap.set("n", "<leader>sb", function()
	Snacks.picker.grep_buffers()
end, { desc = "Search Text in Open Buffers" })

-- git
vim.keymap.set("n", "<leader>gc", function()
	Snacks.picker.git_log_file()
end, { desc = "Git File Commit History" })
vim.keymap.set("n", "<leader>gs", function()
	Snacks.picker.git_status()
end, { desc = "Search Git Status" })
vim.keymap.set("n", "<leader>gd", function()
	Snacks.picker.git_diff()
end, { desc = "Git Diff" })
vim.keymap.set("n", "<leader>gb", function()
	Snacks.picker.git_branches()
end, { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gp", function()
	Snacks.picker.gh_pr()
end, { desc = "GitHub Pull Requests" })
vim.keymap.set("n", "<leader>gi", function()
	Snacks.picker.gh_issue()
end, { desc = "GitHub Issues" })
vim.keymap.set("n", "<leader>ga", function()
	Snacks.picker.gh_actions()
end, { desc = "GitHub Actions" })
vim.keymap.set("n", "<leader>gg", ":Git<CR>", { desc = "Git Status" })
vim.keymap.set("n", "<leader>gw", ":Git blame<CR>", { desc = "Git Blame" })

-- Oil
local oil = require("oil")
vim.keymap.set("n", "<leader>.", ":Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>-o", ":e oil-ssh://s406763@delta2.central.cranfield.ac.uk/<CR>", { desc = "Open SSH" })
vim.keymap.set("n", "<leader>-h", ":e ~/Projects/<CR>", { desc = "Open project home" })

-- Format with null-ls
-- vim.keymap.set("n", "<leader>cf", function()
-- 	vim.lsp.buf.format({ async = true })
-- end, { noremap = true, silent = true, desc = "Format file with null-ls" })
-- Format with conform
vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({ async = true })
end, { noremap = true, silent = true, desc = "Format file with conform" })

-- lsp
-- Goto (under <leader>g for "goto")
vim.keymap.set("n", "<leader>ld", Snacks.picker.lsp_definitions, { desc = "Goto Definition" })
vim.keymap.set("n", "<leader>lD", Snacks.picker.lsp_declarations, { desc = "Goto Declaration" })
vim.keymap.set("n", "<leader>lr", Snacks.picker.lsp_references, { desc = "Goto References" })
vim.keymap.set("n", "<leader>li", Snacks.picker.lsp_implementations, { desc = "Goto Implementation" })
vim.keymap.set("n", "<leader>lt", Snacks.picker.lsp_type_definitions, { desc = "Goto Type Definition" })
vim.keymap.set("n", "<leader>ls", Snacks.picker.lsp_symbols, { desc = "Goto Symbols" })
vim.keymap.set("n", "<leader>lw", Snacks.picker.lsp_workspace_symbols, { desc = "Goto Workspace Symbols" })

-- Hover / Info
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
vim.keymap.set("n", "<leader>lh", vim.lsp.buf.signature_help, { desc = "Signature Help" })
vim.keymap.set("n", "<Esc>", "<cmd>fclose<CR>", { desc = "Close LSP hover window", remap = false })

-- Signature help in new window for readability
vim.keymap.set("n", "<leader>lk", custom_func.big_hover, {
	desc = "Large Hover",
})
vim.keymap.set("n", "<leader>ll", custom_func.vsplit_hover, {
	desc = "Split Hover",
})

-- Refactor
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

-- Diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "<leader>cd", Snacks.picker.diagnostics_buffer, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>cp", Snacks.picker.diagnostics, { desc = "Diagnostics (Project)" })

-- Workspace management
-- vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add Workspace Folder" })
-- vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove Workspace Folder" })
-- vim.keymap.set("n", "<leader>wl", function()
-- 	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
-- end, { desc = "List Workspace Folders" })

-- Window operations
vim.keymap.set("n", "<leader>w", "<C-w>", { desc = "Window management", silent = true })

-- Markview deactivate
vim.keymap.set("n", "<leader>mv", ":Markview<CR>", { desc = "Toggle Markview" })

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
		vim.api.nvim_input("j")
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
vim.keymap.set("n", "<leader>st", function()
	Snacks.picker.todo_comments()
end, { desc = "Find TODO comments" })
vim.keymap.set("n", "<leader>sT", function()
	Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
end, { desc = "Find Todo/Fix/Fixme" })
vim.keymap.set("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- Jupynium
vim.keymap.set(
	{ "n", "x" },
	"<leader>nx",
	"<cmd>JupyniumExecuteSelectedCells<CR>",
	{ buffer = buf_id, desc = "Jupynium execute selected cells" }
)
vim.keymap.set(
	{ "n", "x" },
	"<leader>nc",
	"<cmd>JupyniumClearSelectedCellsOutputs<CR>",
	{ buffer = buf_id, desc = "Jupynium clear selected cells" }
)
vim.keymap.set(
	{ "n" },
	"<leader>nK",
	"<cmd>JupyniumKernelHover<cr>",
	{ buffer = buf_id, desc = "Jupynium hover (inspect a variable)" }
)
vim.keymap.set(
	{ "n", "x" },
	"<leader>ng",
	"<cmd>JupyniumScrollToCell<cr>",
	{ buffer = buf_id, desc = "Jupynium scroll to cell" }
)
vim.keymap.set(
	{ "n", "x" },
	"<leader>no",
	"<cmd>JupyniumToggleSelectedCellsOutputsScroll<cr>",
	{ buffer = buf_id, desc = "Jupynium toggle selected cell output scroll" }
)
vim.keymap.set(
	{ "n" },
	"<leader>na",
	"<cmd>JupyniumStartAndAttachToServer<cr>",
	{ buffer = buf_id, desc = "Jupynium start and attach to server" }
)
-- JupyniumStartSync [filename / tab_index]
vim.keymap.set({ "n" }, "<leader>ns", function()
	vim.ui.input({ prompt = "Enter filename or tab index: " }, function(input)
		if input and input ~= "" then
			vim.cmd("JupyniumStartSync " .. input)
		end
	end)
end, { buffer = buf_id, desc = "Jupynium start sync (enter tab/path to file)" })
vim.keymap.set({ "n" }, "<leader>nw", "<cmd>JupyniumStopSync<cr>", { buffer = buf_id, desc = "Jupynium stop sync" })
vim.keymap.set("", "<PageUp>", "<cmd>JupyniumScrollUp<cr>", { buffer = buf_id, desc = "Jupynium scroll up" })
vim.keymap.set("", "<PageDown>", "<cmd>JupyniumScrollDown<cr>", { buffer = buf_id, desc = "Jupynium scroll down" })

-- You can also specify a list of valid jump keywords

-- HACK: Manage Markdown tasks in Neovim similar to Obsidian | Create weekly task management notes with
-- automatic links to daily journals of all days in the week
-- Inspired by Linkarzu on Youtube

vim.keymap.set(
	"n",
	"<leader>ftw",
	tasks.create_weekly,
	{ desc = "New weekly tasks note with daily links and template" }
)

vim.keymap.set("n", "<leader>ftn", tasks.create_weekly_next, { desc = "New weekly tasks note for next week" })

vim.keymap.set("n", "<leader>ftc", tasks.find_tasks_completed, { desc = "Search for completed tasks with week number" })

vim.keymap.set(
	"n",
	"<leader>ftt",
	tasks.find_tasks_incomplete,
	{ desc = "Search for incomplete tasks with week numbers" }
)

vim.keymap.set("n", "<leader>ftf", tasks.search_task_files, { desc = "Search weekly task files" })

-- HACK: Manage Markdown tasks in Neovim similar to Obsidian | Telescope to List Completed and Pending Tasks
-- https://youtu.be/59hvZl077hM
--
-- If there is no `untoggled` or `done` label on an item, mark it as done
-- and move it to the "## completed tasks" markdown heading in the same file, if
-- the heading does not exist, it will be created, if it exists, items will be
-- appended to it at the top lamw25wmal
--
-- If an item is moved to that heading, it will be added the `done` label
vim.keymap.set("n", "<M-x>", tasks.toggle_task, { desc = "[P]Toggle task and move it to 'done'" })

-- Toggle LSP inlay hints (Neovim ≥0.10)
vim.keymap.set("n", "<leader>ci", function()
	local bufnr = 0 -- 0 = current buffer
	local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
	vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
end, { desc = "Toggle Inlay Hints" })

-- Typst preview
vim.keymap.set("n", "<leader>tp", ":TypstPreview<CR>", { desc = "Typst Preview" })

-- Live preview
vim.keymap.set("n", "<leader>lp", ":LivePreview start<CR>", { desc = "Live Preview" })
