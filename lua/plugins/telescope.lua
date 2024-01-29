-- return {
--   {
--     'nvim-telescope/telescope.nvim',
--     tag = '0.1.5',
--     dependencies = {
--       'nvim-lua/plenary.nvim',
--       "nvim-telescope/telescope-fzf-native.nvim",
--       build = "make",
--       config = function()
--         require("telescope").load_extension("fzf")
--       end,
--     },
--     config = function()
--       local builtin = require 'telescope.builtin'
--       vim.keymap.set('n', '<C-p>', builtin.find_files, {})
--       vim.keymap.set('n', '<C-g>', builtin.live_grep, {})
--       vim.keymap.set('n', '<C-f>', builtin.current_buffer_fuzzy_find, {})
--       vim.keymap.set('n', '<C-r>', builtin.oldfiles, {})
--       vim.keymap.set('n', '<C-b>', builtin.buffers, {})
--       -- vim.keymap.set('n', '<buffer> <C-b>', builtin.buffers, {})
--     end,
--   },
-- }






return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build =
        "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        cond = vim.fn.executable("cmake") == 1,
      },
    },
    config = function()
      local actions = require("telescope.actions")

      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-x>"] = actions.delete_buffer,
            },
          },
          file_ignore_patterns = {
            "node_modules",
            "yarn.lock",
            ".git",
            ".sl",
            "_build",
            ".next",
          },
          hidden = true,
        },
      })
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<C-p>', builtin.find_files, {})
      vim.keymap.set('n', '<C-g>', builtin.live_grep, {})
      vim.keymap.set('n', '<C-f>', builtin.current_buffer_fuzzy_find, {})
      vim.keymap.set('n', '<C-r>', builtin.oldfiles, {})
      vim.keymap.set('n', '<C-b>', builtin.buffers, {})

      -- Enable telescope fzf native, if installed
      pcall(require("telescope").load_extension, "fzf")
    end,
  },
}
