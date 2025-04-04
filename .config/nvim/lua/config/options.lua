-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable line numbers
-- vim.opt.number = false
vim.opt.relativenumber = false
vim.o.title = true
vim.o.titlestring = "%t" -- %t is the buffer’s tail (filename)
vim.cmd("colorscheme delek")
-- always_show_bufferline = true,

-- Preserve yanked text when pasting in visual mode
vim.keymap.set("x", "p", '"_dP')

vim.opt.timeoutlen = 0 -- Adjust the delay (in ms) before which-key appears
