-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.snacks_animate = false
-- vim.g.snacks_scroll = false

-- backup
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/state/nvim/undo"
vim.opt.undofile = true

-- open splits in a more natural direction
-- https://vimtricks.com/p/open-splits-more-naturally/
vim.opt.splitright = true
vim.opt.splitbelow = true

-- indent
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- search
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true

-- colors
vim.opt.termguicolors = true
vim.g.syntax = "enable"
vim.o.winblend = 0

-- clipboard
vim.opt.clipboard = ""
