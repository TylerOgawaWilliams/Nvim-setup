vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.autoformat = true
vim.g.deprecation_warnings = false

local opt = vim.opt

-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.confirm = true
opt.cursorline = true
opt.mouse = ""
opt.relativenumber = true
opt.splitright = true
