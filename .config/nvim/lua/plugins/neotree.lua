-- A highly customizable file explorer tree that provides a sleek UI for managing files and directories
-- Features git integration, filtering options, and dynamic updates
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        hide_gitignored = false,
      },
    },
  },
}
