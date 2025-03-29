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

-- Neo-tree explorer mappings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "neo-tree",
  callback = function()
    vim.keymap.set("n", "<C-h>", "4h", { noremap = true, silent = true, buffer = true })
    vim.keymap.set("n", "<C-j>", "4j", { noremap = true, silent = true, buffer = true })
    vim.keymap.set("n", "<C-k>", "4k", { noremap = true, silent = true, buffer = true })
    vim.keymap.set("n", "<C-l>", "4l", { noremap = true, silent = true, buffer = true })
  end,
})

-- Move cursor to top of window
vim.keymap.set("n", "gh", ":normal! H<CR>", { desc = "Move cursor to top of window" })
-- Move cursor to bottom of window
vim.keymap.set("n", "gl", ":normal! L<CR>", { desc = "Move cursor to bottom of window" })

-- move between tabs
vim.keymap.set("n", "<A-h>", "gT", { desc = "Previous tab" })
vim.keymap.set("n", "<A-l>", "gt", { desc = "Next tab" })

local function mirror_brackets_to_umlauts()
  local mappings = {
    { "m", "method start" },
    { "e", "error" },
    -- Add more pairs here if needed, e.g., {"f", "function"}
  }
  for _, map in ipairs(mappings) do
    local key = map[1]
    local desc = map[2]
    vim.keymap.set("n", "ö" .. key, "[" .. key, { desc = "Previous " .. desc })
    vim.keymap.set("n", "ä" .. key, "]" .. key, { desc = "Next " .. desc })
  end
end

mirror_brackets_to_umlauts()
