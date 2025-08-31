local colors = require("catppuccin.palettes").get_palette()
return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = false,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- event = {
	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
	--   -- refer to `:h file-pattern` for more examples
	--   "BufReadPre path/to/my-vault/*.md",
	--   "BufNewFile path/to/my-vault/*.md",
	-- },
	opts = {
		workspaces = {
			{
				name = "personal",
				path = "~/Notes",
			},
		},
		notes_subdir = ".",
		legacy_commands = false,
		templates = {
			folder = ".Templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
			-- A map for custom variables, the key should be the variable and the value a function
			substitutions = {},
		},
		daily_notes = {
			folder = "journal",
			date_format = "%Y-%m-%d",
			alias_format = "%d %B, %Y",
			default_tags = { "daily_journal" },
			template = "daily.md",
		},
		completion = {
			nvim_cmp = true,
			min_chars = 2,
			create_new = false,
		},
		new_notes_location = "notes_subdir",
		-- Optional, customize how note IDs are generated given an optional title.
		---@param title string|?
		---@return string
		note_id_func = function(title)
			local note_prefix = ""
			if title and title:match("%S") then -- check if title exists and has at least one non-space char
				note_prefix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
			else
				for _ = 1, 4 do
					note_prefix = note_prefix .. string.char(math.random(65, 90))
				end
			end
			return note_prefix .. "-" .. tostring(os.time())
		end,
		-- Optional, customize how note file names are generated given the ID, target directory, and title.
		---@param spec { id: string, dir: obsidian.Path, title: string|? }
		---@return string|obsidian.Path The full path to the new note.
		note_path_func = function(spec)
			-- This is equivalent to the default behavior.
			local path = spec.dir / tostring(spec.id)
			return path:with_suffix(".md")
		end,
		-- Optional, customize how wiki links are formatted. You can set this to one of:
		-- _ "use_alias_only", e.g. '[[Foo Bar]]'
		-- _ "prepend*note_id", e.g. '[[foo-bar|Foo Bar]]'
		-- * "prepend*note_path", e.g. '[[foo-bar.md|Foo Bar]]'
		-- * "use_path_only", e.g. '[[foo-bar.md]]'
		-- Or you can set it to a function that takes a table of options and returns a string, like this:
		-- wiki_link_func = function(opts)
		-- 	return require("obsidian.util").wiki_link_id_prefix(opts)
		-- end,
		wiki_link_func = "prepend_note_id",
		markdown_link_func = "prepend_note_id",
		preffered_link_style = "wiki",
		diable_frontmatter = "false",
		-- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
		-- URL it will be ignored but you can customize this behavior here.
		---@param url string
		follow_url_func = function(url)
			-- Open the URL in the default web browser.
			-- vim.fn.jobstart({"open", url})	-- Mac OS
			vim.fn.jobstart({ "xdg-open", url }) -- linux
			-- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
			-- vim.ui.open(url) -- need Neovim 0.10.0+
		end,
		picker = {
			-- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
			name = "telescope.nvim",
			-- Optional, configure key mappings for the picker. These are the defaults.
			-- Not all pickers support all mappings.
			note_mappings = {
				-- Create a new note from your query.
				new = "<C-x>",
				-- Insert a link to the selected note.
				insert_link = "<C-l>",
			},
			tag_mappings = {
				-- Add tag(s) to current note.
				tag_note = "<C-x>",
				-- Insert a tag at the current location.
				insert_tag = "<C-l>",
			},
		},
		-- Optional, sort search results by "path", "modified", "accessed", or "created". The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
		-- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
		sort_by = "accessed",
		sort_reversed = true,
		ui = {
			enable = false,
			ignore_conceal_warn = true, -- set to true to disable conceallevel specific warning
			update_debounce = 200, -- update delay after a text change (in milliseconds)
			max_file_length = 5000, -- disable UI features for files with more than this many lines
			-- Use bullet marks for non-checkbox lists.
			bullets = { char = "•", hl_group = "ObsidianBullet" },
			external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
			-- Replace the above with this if you don't have a patched font:
			-- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
			reference_text = { hl_group = "ObsidianRefText" },
			highlight_text = { hl_group = "ObsidianHighlightText" },
			tags = { hl_group = "ObsidianTag" },
			block_ids = { hl_group = "ObsidianBlockID" },
			hl_groups = {
				-- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
				ObsidianTodo = { bold = true, fg = colors.mantle },
				ObsidianDone = { bold = true, fg = colors.sky },
				ObsidianRightArrow = { bold = true, fg = colors.mantle },
				ObsidianTilde = { bold = true, fg = colors.yellow },
				ObsidianImportant = { bold = true, fg = colors.red },
				ObsidianBullet = { bold = true, fg = colors.sky },
				ObsidianRefText = { underline = true, fg = colors.mauve },
				ObsidianExtLinkIcon = { fg = colors.mauve },
				ObsidianTag = { italic = true, fg = colors.sky },
				ObsidianBlockID = { italic = true, fg = colors.sky },
				ObsidianHighlightText = { bg = "#5c5453" },
			},
		},

		footer = {
			enabled = true,
			format = "{{backlinks}} backlinks  {{properties}} properties  {{words}} words  {{chars}} chars",
			hl_group = "Comment",
			separator = string.rep("-", 80),
		},
		---@class obsidian.config.CheckboxOpts
		---
		---Order of checkbox state chars, e.g. { " ", "x" }
		---@field order? string[]
		checkbox = {
			order = { " ", "x", "!", "~", ">" },
		},
	},
}
