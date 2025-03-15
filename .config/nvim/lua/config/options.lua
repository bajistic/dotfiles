-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
local opt = vim.opt

-- UI
opt.number = true         -- Show line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true     -- Highlight current line
opt.signcolumn = "yes"    -- Always show sign column
opt.showmode = false      -- Don't show mode, we'll use statusline
opt.termguicolors = true  -- True color support
opt.laststatus = 3        -- Global statusline

-- Behavior
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.mouse = "a"              -- Enable mouse in all modes
opt.undofile = true          -- Persistent undo
opt.swapfile = false         -- No swap file
opt.updatetime = 250         -- Faster completion
opt.timeoutlen = 300         -- Time to wait for a mapped sequence
opt.completeopt = "menu,menuone,noselect" -- Better completion

-- Tabs & Indentation
opt.expandtab = true   -- Use spaces instead of tabs
opt.shiftwidth = 2     -- Size of an indent
opt.tabstop = 2        -- Number of spaces tabs count for
opt.softtabstop = 2    -- Edit as if tabs are this width
opt.smartindent = true -- Insert indents automatically
opt.wrap = false       -- Don't wrap lines

-- Search
opt.ignorecase = true  -- Ignore case in search patterns
opt.smartcase = true   -- Override ignorecase if search pattern has uppercase
opt.incsearch = true   -- Search as characters are entered
opt.hlsearch = true    -- Highlight all matches

-- Misc
opt.backup = false     -- No backup files
opt.scrolloff = 8      -- Lines of context
opt.sidescrolloff = 8  -- Columns of context
opt.splitbelow = true  -- Put new windows below current
opt.splitright = true  -- Put new windows right of current