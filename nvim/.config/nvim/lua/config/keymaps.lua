-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Track the notification window ID
local gh_notification_win_id = nil

vim.keymap.set("n", "<C-7>", function()
  -- Check if notifications window is already open, close it if it is
  if gh_notification_win_id and vim.api.nvim_win_is_valid(gh_notification_win_id) then
    vim.api.nvim_win_close(gh_notification_win_id, true)
    gh_notification_win_id = nil
    return
  end

  local success, git_notifications = pcall(function()
    return vim.fn.system("gh notify -s -a -n5"):gsub("\n$", "")
  end)

  if not success or git_notifications == "" then
    require("noice").notify("No GitHub notifications or error running command", "warn")
    return
  end

  -- Strip ANSI escape sequences and format output
  local cleaned = git_notifications:gsub("\27%[[%d;]+m", "") -- Remove ANSI color codes
  local formatted = {}
  for line in cleaned:gmatch("[^\r\n]+") do
    -- Extract date/time and description
    local date_time, description = line:match("%s*(%d+/%w+ %d+:%d+)%s*(.*)")
    if date_time and description then
      table.insert(formatted, string.format("%s  %s", date_time, description))
    end
  end

  -- Create a buffer for the notifications
  local buf = vim.api.nvim_create_buf(false, true)

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)

  -- Calculate window dimensions
  local width = math.min(160, vim.o.columns - 4)
  local height = math.min(#formatted + 1, 15)

  -- Center the window
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create floating window
  local padding = 1 -- top, left, bottom, right
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width - 2 * padding,
    height = height - 1 * padding,
    row = row + padding,
    col = col + padding,
    style = "minimal",
    border = "rounded",
    title = "GitHub Notifications",
    title_pos = "center",
  })

  -- Store window ID for toggle functionality
  gh_notification_win_id = win

  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].filetype = "gh-notifications"

  -- Add keymaps to close the window
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })
end, { desc = "Show GitHub notifications", silent = true })
