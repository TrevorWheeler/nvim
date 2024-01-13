vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- scroll center
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- move text around
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- go to Netrw Directory Listing
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

vim.keymap.set('i', '<C-c>', '<Esc>')

vim.keymap.set('n', 'Q', '<nop>')

vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })
vim.keymap.set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- Join line with current and jump cursor to original position
vim.keymap.set('n', 'J', 'mzJz')

