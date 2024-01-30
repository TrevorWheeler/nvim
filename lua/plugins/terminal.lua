return {
  'akinsho/toggleterm.nvim',
  version = '*',
  -- opts = {
  --   start_in_insert = true,
  --   direction = 'float',
  --   open_mapping = [[<c-\>]],
  -- },
  config = function()
    require('toggleterm').setup {
      start_in_insert = true,
      direction = 'float',
      -- open_mapping = [[<c-\>]],
    }
    vim.keymap.set('n', '<C-t>', ':ToggleTerm<CR>', { noremap = true, silent = true })
    vim.keymap.set('t', '<C-t>', '<C-\\><C-n>:ToggleTerm<CR>', { noremap = true, silent = true })
  end,
}
-- {'akinsho/toggleterm.nvim', version = "*", config = true}
