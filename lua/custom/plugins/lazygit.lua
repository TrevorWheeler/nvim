return {
  "kdheepak/lazygit.nvim",
  lazy = true,
  cmd = { "LazyGit" },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>gl", "<cmd>LazyGit<cr>", desc = "[G]it [L]azygit" },
  },
}
