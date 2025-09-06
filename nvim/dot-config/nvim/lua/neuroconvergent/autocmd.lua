-- Reroute shell commands with `:Shell` to output to nvim-notify
local function notify_shell(cmd)
  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Error: " .. output, vim.log.levels.ERROR, { title = "Shell Error" })
  else
    vim.notify(output, vim.log.levels.INFO, { title = "Shell Output" })
  end
end

vim.api.nvim_create_user_command("Shell", function(opts)
  notify_shell(opts.args)
end, { nargs = "+" })

vim.keymap.set('n', '<leader>sh', ':Shell ')

-- Auto set current working directory to focussed buffer
-- vim.api.nvim_create_autocmd("BufEnter", {
--   callback = function()
--     local file_dir = vim.fn.expand("%:p:h")
--     if vim.fn.isdirectory(file_dir) == 1 then
--       vim.cmd("lcd " .. file_dir)
--     end
--   end,
-- })
