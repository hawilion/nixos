-- Neovim Init (flake-managed)
-- This file is copied from ./nvim-config/init.lua in your flake

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true

-- Highlight search
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Keymaps
vim.g.mapleader = " "

-- Save with Ctrl+S
vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a")

-- Quit with Ctrl+Q
vim.keymap.set("n", "<C-q>", ":q<CR>")
vim.keymap.set("i", "<C-q>", "<Esc>:q<CR>")

-- Plugins
-- You can add lazy.nvim or packer here later if you want
