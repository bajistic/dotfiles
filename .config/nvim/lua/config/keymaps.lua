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
vim.keymap.set("n", "gh", ":normal! H<CR>", { desc = "Move cursor to top of window", silent = true })
-- Move cursor to bottom of window
vim.keymap.set("n", "gl", ":normal! L<CR>", { desc = "Move cursor to bottom of window", silent = true })

-- move between tabs
if vim.fn.has("macunix") == 1 then
  -- Mac-specific mappings
  vim.keymap.set("n", "ª", "gT", { desc = "Previous tab" }) -- Option-h
  vim.keymap.set("n", "¬", "gt", { desc = "Next tab" }) -- Option-l
else
  -- Non-Mac mappings
  vim.keymap.set("n", "<A-h>", "gT", { desc = "Previous tab" })
  vim.keymap.set("n", "<A-l>", "gt", { desc = "Next tab" })
end

-- vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous tab" })
-- vim.keymap.set("n", "<S-l>", "gt", { desc = "Next tab" })

-- Pick tab/buffer
vim.keymap.set("n", "<leader><tab>p", function()
  require("bufferline").pick()
end, { desc = "Pick tab/buffer" })

-- Mirror [ and ] keymaps to ö and ä
-- Buffer navigation
vim.keymap.set("n", "öb", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "äb", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Diagnostics navigation
vim.keymap.set("n", "öd", function()
  vim.diagnostic.goto_prev()
end, { desc = "Prev Diagnostic" })
vim.keymap.set("n", "äd", function()
  vim.diagnostic.goto_next()
end, { desc = "Next Diagnostic" })

-- Error navigation
vim.keymap.set("n", "öe", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Prev Error" })
vim.keymap.set("n", "äe", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next Error" })

-- Warning navigation
vim.keymap.set("n", "öw", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Prev Warning" })
vim.keymap.set("n", "äw", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Next Warning" })

-- Quickfix navigation
vim.keymap.set("n", "öq", function()
  if require("trouble").is_open() then
    require("trouble").prev({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cprev)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = "Previous Trouble/Quickfix Item" })

vim.keymap.set("n", "äq", function()
  if require("trouble").is_open() then
    require("trouble").next({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cnext)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = "Next Trouble/Quickfix Item" })

-- Todo comments navigation
vim.keymap.set("n", "öt", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous Todo Comment" })
vim.keymap.set("n", "ät", function()
  require("todo-comments").jump_next()
end, { desc = "Next Todo Comment" })

-- Git hunks navigation
vim.keymap.set("n", "öh", function()
  if vim.wo.diff then
    vim.cmd.normal({ "[c", bang = true })
  else
    require("gitsigns").nav_hunk("prev")
  end
end, { desc = "Prev Hunk" })

vim.keymap.set("n", "äh", function()
  if vim.wo.diff then
    vim.cmd.normal({ "]c", bang = true })
  else
    require("gitsigns").nav_hunk("next")
  end
end, { desc = "Next Hunk" })

-- First/Last git hunk
vim.keymap.set("n", "öH", function()
  require("gitsigns").nav_hunk("first")
end, { desc = "First Hunk" })
vim.keymap.set("n", "äH", function()
  require("gitsigns").nav_hunk("last")
end, { desc = "Last Hunk" })

-- Treesitter text objects navigation
vim.keymap.set("n", "öf", function()
  require("nvim-treesitter.textobjects.move").goto_previous_start("@function.outer")
end, { desc = "Previous Function Start" })
vim.keymap.set("n", "äf", function()
  require("nvim-treesitter.textobjects.move").goto_next_start("@function.outer")
end, { desc = "Next Function Start" })

vim.keymap.set("n", "öF", function()
  require("nvim-treesitter.textobjects.move").goto_previous_end("@function.outer")
end, { desc = "Previous Function End" })
vim.keymap.set("n", "äF", function()
  require("nvim-treesitter.textobjects.move").goto_next_end("@function.outer")
end, { desc = "Next Function End" })

vim.keymap.set("n", "öc", function()
  require("nvim-treesitter.textobjects.move").goto_previous_start("@class.outer")
end, { desc = "Previous Class Start" })
vim.keymap.set("n", "äc", function()
  require("nvim-treesitter.textobjects.move").goto_next_start("@class.outer")
end, { desc = "Next Class Start" })

vim.keymap.set("n", "öC", function()
  require("nvim-treesitter.textobjects.move").goto_previous_end("@class.outer")
end, { desc = "Previous Class End" })
vim.keymap.set("n", "äC", function()
  require("nvim-treesitter.textobjects.move").goto_next_end("@class.outer")
end, { desc = "Next Class End" })

vim.keymap.set("n", "öa", function()
  require("nvim-treesitter.textobjects.move").goto_previous_start("@parameter.inner")
end, { desc = "Previous Parameter Start" })
vim.keymap.set("n", "äa", function()
  require("nvim-treesitter.textobjects.move").goto_next_start("@parameter.inner")
end, { desc = "Next Parameter Start" })

vim.keymap.set("n", "öA", function()
  require("nvim-treesitter.textobjects.move").goto_previous_end("@parameter.inner")
end, { desc = "Previous Parameter End" })
vim.keymap.set("n", "äA", function()
  require("nvim-treesitter.textobjects.move").goto_next_end("@parameter.inner")
end, { desc = "Next Parameter End" })
