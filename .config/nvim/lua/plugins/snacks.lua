-- ~/.config/nvim/lua/plugins/snacks.lua
return {
  ---@type snacks.Config
  "folke/snacks.nvim", -- Adjust if the repo name differs
  opts = {
    ---@type table<string, snacks.win.Config>
    scroll = {
      enabled = false, -- Default to disabled
    },
    styles = {
      scratch = {
        -- your styles configuration comes here
        -- or leave it empty to use the default settings
        width = 120,
        height = 90,
        bo = { buftype = "", buflisted = false, bufhidden = "hide", swapfile = false },
        minimal = false,
        noautocmd = false,
        -- position = "right",
        zindex = 20,
        wo = {
          winhighlight = "NormalFloat:Normal",
          wrap = true, -- Add this line to enable text wrap
          linebreak = true, -- Optional: Makes wrap at word boundaries instead of characters
        },
        border = "rounded",
        title_pos = "center",
        footer_pos = "center",
      },
    },
  },
}
