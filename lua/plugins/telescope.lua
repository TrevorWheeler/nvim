return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
      'nvim-lua/plenary.nvim',
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
    config = function()
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<C-p>', builtin.find_files, {})
      vim.keymap.set('n', '<C-g>', builtin.live_grep, {})
      vim.keymap.set('n', '<C-f>', builtin.current_buffer_fuzzy_find, {})
      vim.keymap.set('n', '<C-r>', builtin.oldfiles, {})
      vim.keymap.set('n', '<C-b>', builtin.buffers, {})
      -- vim.keymap.set('n', '<buffer> <C-b>', builtin.buffers, {})
    end,
  },
}



