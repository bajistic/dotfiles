-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- Normal mode mappings
vim.keymap.set("n", "<C-h>", "4h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "4j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "4k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "4l", { noremap = true, silent = true })

-- Optional: Visual mode mappings
vim.keymap.set("v", "<C-h>", "4h", { noremap = true, silent = true })
vim.keymap.set("v", "<C-j>", "4j", { noremap = true, silent = true })
vim.keymap.set("v", "<C-k>", "4k", { noremap = true, silent = true })
vim.keymap.set("v", "<C-l>", "4l", { noremap = true, silent = true })

-- create a simple ascii art
