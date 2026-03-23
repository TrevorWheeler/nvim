return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen -- %<cr>", desc = "[G]it [D]iff current file" },
  },
  opts = {},
}
