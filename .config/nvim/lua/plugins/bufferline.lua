return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      mode = "buffers", -- set to "tabs" to only show tabpages instead
      numbers = "buffer_id", -- Show buffer numbers (1, 2, 3, etc.)
      show_buffer_close_icons = true,
      show_tab_indicators = true,
      -- tab_size = 18,
      diagnostics = "nvim_lsp", -- Optional: show LSP diagnostics
      -- always_show_bufferline = true,
      tabpages = true, -- Show tab numbers in the bufferline
      -- sort_by = 'insert_after_current' |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
      sort_by = "relative_directory",
      pick = {
        alphabet = "abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890",
      },
    },
  },
}
