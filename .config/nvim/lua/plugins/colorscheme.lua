return {
  -- tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
    },
  },

  -- Set colorscheme
  {
    "LazyVim/LazyVim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "tokyonight"
    end,
  },
}