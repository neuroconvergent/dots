return {
	"yousefhadder/markdown-plus.nvim",
	ft = { "markdown", "quarto" },
	opts = {
		keymaps = {
			enabled = false,
		},
	},
	init = function()
		local patterns = { "markdown", "quarto" }
		vim.api.nvim_create_autocmd("FileType", {
			pattern = patterns,
			callback = function(event)
				local base_opts = { buffer = event.buf }
				local function map(mode, lhs, rhs, extra)
					local opts = extra and vim.tbl_extend("force", base_opts, extra) or base_opts
					vim.keymap.set(mode, lhs, rhs, opts)
				end

				-- Normal mode
				map("n", "<A-b>", "<Plug>(MarkdownPlusBold)", { desc = "Toggle bold" })
				map("n", "<A-i>", "<Plug>(MarkdownPlusItalic)", { desc = "Toggle italic" })
				map("n", "<A-s>", "<Plug>(MarkdownPlusStrikethrough)", { desc = "Toggle strikethrough" })
				map("n", "<A-k>", "<Plug>(MarkdownPlusCode)", { desc = "Toggle inline code" })
				map("n", "<A-z>", "<Plug>(MarkdownPlusClearFormatting)", { desc = "Clear formatting" })

				-- Visual mode
				map("x", "<A-b>", "<Plug>(MarkdownPlusBold)", { desc = "Toggle bold" })
				map("x", "<A-I>", "<Plug>(MarkdownPlusItalic)", { desc = "Toggle italic" })
				map("x", "<A-s>", "<Plug>(MarkdownPlusStrikethrough)", { desc = "Toggle strikethrough" })
				map("x", "<A-c>", "<Plug>(MarkdownPlusCode)", { desc = "Toggle inline code" })
				map("x", "<leader>mw", "<Plug>(MarkdownPlusCodeBlock)", { desc = "Format selection as code block" })

				-- Headers
				map("n", "]h", "<Plug>(MarkdownPlusNextHeader)", { desc = "Next header" })
				map("n", "[h", "<Plug>(MarkdownPlusPrevHeader)", { desc = "Previous header" })
				map("n", "<<", "<Plug>(MarkdownPlusPromoteHeader)", { noremap = true, desc = "Promote header" })
				map("n", ">>", "<Plug>(MarkdownPlusDemoteHeader)", { noremap = true, desc = "Demote header" })
				map("n", "<leader>toc", "<Plug>(MarkdownPlusGenerateTOC)", { desc = "Generate TOC" })
				map("n", "<leader>tou", "<Plug>(MarkdownPlusUpdateTOC)", { desc = "Update TOC" })
				map("n", "<leader>tO", "<Plug>(MarkdownPlusOpenTocWindow)", { desc = "Toggle TOC window" })
				map("n", "<CR>", "<Plug>(MarkdownPlusFollowLink)", { noremap = true, desc = "Follow link" })

				-- Header levels (H1-H6)
				for i = 1, 6 do
					map("n", "<leader>" .. i, "<Plug>(MarkdownPlusHeader" .. i .. ")", { desc = "Toggle H" .. i })
				end
				map("x", "<A-z>", "<Plug>(MarkdownPlusClearFormatting)", { desc = "Clear formatting" })

				-- Links
				map("n", "<leader>li", "<Plug>(MarkdownPlusInsertLink)", { desc = "Insert link" })
				map("v", "<leader>li", "<Plug>(MarkdownPlusSelectionToLink)", { desc = "Convert selection to link" })
				map("n", "<leader>le", "<Plug>(MarkdownPlusEditLink)", { desc = "Edit link" })
				map("n", "<leader>lr", "<Plug>(MarkdownPlusConvertToReference)", { desc = "Convert to reference link" })
				map("n", "<leader>ln", "<Plug>(MarkdownPlusConvertToInline)", { desc = "Convert to inline link" })
				map("n", "<leader>la", "<Plug>(MarkdownPlusAutoLinkURL)", { desc = "Auto-link URL" })

				-- Images
				map("n", "<leader>mL", "<Plug>(MarkdownPlusInsertImage)", { desc = "Insert image" })
				map("v", "<leader>mL", "<Plug>(MarkdownPlusSelectionToImage)", { desc = "Convert selection to image" })
				map("n", "<leader>mE", "<Plug>(MarkdownPlusEditImage)", { desc = "Edit image" })
				map("n", "<leader>mA", "<Plug>(MarkdownPlusToggleImageLink)", { desc = "Toggle image/link type" })

				-- Lists
				-- Insert mode
				map("i", "<C-CR>", "<Plug>(MarkdownPlusListEnter)", { desc = "New list item" })
				map("i", "<A-CR>", "<Plug>(MarkdownPlusListShiftEnter)", { desc = "New sub-item" })
				map("i", "<A-l>", "<Plug>(MarkdownPlusListIndent)", { desc = "Indent list item" })
				map("i", "<A-h>", "<Plug>(MarkdownPlusListOutdent)", { desc = "Outdent list item" })
				map("i", "<C-h>", "<Plug>(MarkdownPlusListBackspace)", { desc = "Smart backspace" })
				map("i", "<C-t>", "<Plug>(MarkdownPlusToggleCheckbox)", { desc = "Toggle checkbox" })

				-- Normal mode
				map("n", "<leader>lr", "<Plug>(MarkdownPlusRenumberLists)", { desc = "Renumber ordered lists" })
				map("n", "<leader>ld", "<Plug>(MarkdownPlusDebugLists)", { desc = "Debug lists" })
				map("n", "O", "<Plug>(MarkdownPlusNewListItemAbove)", { noremap = true, desc = "New item above" })
				map("n", "<leader>mx", "<Plug>(MarkdownPlusToggleCheckbox)", { desc = "Toggle checkbox" })

				-- Visual mode
				map("x", "<leader>mx", "<Plug>(MarkdownPlusToggleCheckbox)", { desc = "Toggle checkbox" })

				-- Quotes
				map({ "n", "x" }, "<C-m>", "<Plug>(MarkdownPlusToggleQuote)", { desc = "Toggle quote" })

				-- Callouts
				map("n", "<leader>mc", "<Plug>(MarkdownPlusInsertCallout)", { desc = "Insert callout" })
				map("x", "<leader>mc", "<Plug>(MarkdownPlusInsertCallout)", { desc = "Surround with callout" })
				map("n", "<leader>mC", "<Plug>(MarkdownPlusToggleCalloutType)", { desc = "Cycle callout type" })
				map("n", "<leader>m>c", "<Plug>(MarkdownPlusConvertToCallout)", { desc = "Blockquote to callout" })
				map("n", "<leader>m>b", "<Plug>(MarkdownPlusConvertToBlockquote)", { desc = "Callout to blockquote" })

				-- Footnotes
				map("n", "<leader>mfi", "<Plug>(MarkdownPlusFootnoteInsert)", { desc = "Insert footnote" })
				map("n", "<leader>mfe", "<Plug>(MarkdownPlusFootnoteEdit)", { desc = "Edit footnote" })
				map("n", "<leader>mfd", "<Plug>(MarkdownPlusFootnoteDelete)", { desc = "Delete footnote" })
				map(
					"n",
					"<leader>mfg",
					"<Plug>(MarkdownPlusFootnoteGotoDefinition)",
					{ desc = "Goto footnote definition" }
				)
				map(
					"n",
					"<leader>mfr",
					"<Plug>(MarkdownPlusFootnoteGotoReference)",
					{ desc = "Goto footnote reference" }
				)
				map("n", "<leader>mfn", "<Plug>(MarkdownPlusFootnoteNext)", { desc = "Next footnote" })
				map("n", "<leader>mfp", "<Plug>(MarkdownPlusFootnotePrev)", { desc = "Previous footnote" })
				map("n", "<leader>mfl", "<Plug>(MarkdownPlusFootnoteList)", { desc = "List footnotes" })

				-- Tables
				map("n", "<leader>tc", "<Plug>(markdown-plus-table-create)", { desc = "Create table" })
				map("n", "<leader>tf", "<Plug>(markdown-plus-table-format)", { desc = "Format table" })
				map("n", "<leader>tn", "<Plug>(markdown-plus-table-normalize)", { desc = "Normalize table" })
				map("n", "<leader>tir", "<Plug>(markdown-plus-table-insert-row-below)", { desc = "Insert row below" })
				map("n", "<leader>tiR", "<Plug>(markdown-plus-table-insert-row-above)", { desc = "Insert row above" })
				map("n", "<leader>tdr", "<Plug>(markdown-plus-table-delete-row)", { desc = "Delete row" })
				map("n", "<leader>tyr", "<Plug>(markdown-plus-table-duplicate-row)", { desc = "Duplicate row" })
				map(
					"n",
					"<leader>tic",
					"<Plug>(markdown-plus-table-insert-column-right)",
					{ desc = "Insert column right" }
				)
				map(
					"n",
					"<leader>tiC",
					"<Plug>(markdown-plus-table-insert-column-left)",
					{ desc = "Insert column left" }
				)
				map("n", "<leader>tdc", "<Plug>(markdown-plus-table-delete-column)", { desc = "Delete column" })
				map("n", "<leader>tyc", "<Plug>(markdown-plus-table-duplicate-column)", { desc = "Duplicate column" })
				map("n", "<leader>tmk", "<Plug>(markdown-plus-table-move-row-up)", { desc = "Move row up" })
				map("n", "<leader>tmj", "<Plug>(markdown-plus-table-move-row-down)", { desc = "Move row down" })
				map("n", "<leader>tmh", "<Plug>(markdown-plus-table-move-column-left)", { desc = "Move column left" })
				map("n", "<leader>tml", "<Plug>(markdown-plus-table-move-column-right)", { desc = "Move column right" })
			end,
		})
	end,
}
