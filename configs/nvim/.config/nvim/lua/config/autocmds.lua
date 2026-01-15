local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("yank_highlight", { clear = true }),
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("last_location", { clear = true }),
  desc = "Go to last cursor position",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.cmd('normal! g`"zz')
    end
  end,
})

-- Open help in vertical split
autocmd("FileType", {
  pattern = "help",
  command = "wincmd L",
})

-- Auto resize splits
autocmd("VimResized", {
  command = "wincmd =",
})

-- Disable auto comment continuation
autocmd("FileType", {
  group = vim.api.nvim_create_augroup("no_auto_comment", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- dotenv files
autocmd("BufRead", {
  group = vim.api.nvim_create_augroup("dotenv_ft", { clear = true }),
  pattern = { ".env", ".env.*" },
  callback = function()
    vim.bo.filetype = "dosini"
  end,
})

-- Cursorline only in active window
local cursorline_group = vim.api.nvim_create_augroup("active_cursorline", { clear = true })
autocmd({ "WinEnter", "BufEnter" }, {
  group = cursorline_group,
  callback = function()
    vim.opt_local.cursorline = true
  end,
})
autocmd({ "WinLeave", "BufLeave" }, {
  group = cursorline_group,
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

-- LSP reference highlight
local lsp_ref_group = vim.api.nvim_create_augroup("LspReferenceHighlight", { clear = true })
autocmd("CursorMoved", {
  group = lsp_ref_group,
  callback = function()
    if vim.fn.mode() == "i" then
      return
    end
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if client.server_capabilities.documentHighlightProvider then
        vim.lsp.buf.clear_references()
        vim.lsp.buf.document_highlight()
        return
      end
    end
  end,
})
autocmd("CursorMovedI", {
  group = lsp_ref_group,
  callback = function()
    vim.lsp.buf.clear_references()
  end,
})

-- Trim trailing whitespace
autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("trim_whitespace", { clear = true }),
  command = [[%s/\s\+$//e]],
})

-- Undotree layout
-- vim.cmd.packadd("nvim.undotree")
-- autocmd("FileType", {
--   pattern = "nvim-undotree",
--   callback = function()
--     vim.cmd.wincmd("H")
--     vim.api.nvim_win_set_width(0, 40)
--   end,
-- })

-- Close Lazy with Esc
autocmd("FileType", {
  pattern = "lazy",
  callback = function()
    vim.keymap.set("n", "<esc>", function()
      vim.api.nvim_win_close(0, false)
    end, { buffer = true, nowait = true })
  end,
})

-- Close special buffers with q
autocmd("FileType", {
  group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
  pattern = { "git", "help", "man", "qf", "scratch" },
  callback = function(args)
    if args.match ~= "help" or not vim.bo[args.buf].modifiable then
      vim.keymap.set("n", "q", "<cmd>quit<cr>", { buffer = args.buf })
    end
  end,
})
