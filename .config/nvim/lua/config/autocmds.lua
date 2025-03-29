-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ~/.config/nvim/lua/config/autocommands.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.diagnostic.enable(false) -- Disable diagnostics
    vim.opt_local.spell = false -- Disable spelling
  end,
})

-- Set iTerm2 tab title
-- this config made dingllm fail
-- local function set_iterm2_tab_title(title)
--   vim.fn.execute('silent !echo -ne "\\033]0;' .. title .. '\\007"')
-- end
