-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    { '<leader>gs', ':Neotree git_status<CR>', desc = '[G]it [S]tatus tree', silent = true },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    sources = {
      'filesystem',
      'buffers',
      'git_status',
      'trevy_changes',
    },
    default_component_configs = {
      diagnostics = {
        symbols = {
          hint = '󰌵',
          info = '',
          warn = '',
          error = '',
        },
        highlights = {
          hint = 'DiagnosticSignHint',
          info = 'DiagnosticSignInfo',
          warn = 'DiagnosticSignWarn',
          error = 'DiagnosticSignError',
        },
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['T'] = function(state)
            local node = state.tree:get_node()
            local path = node.type == 'directory' and node.path or vim.fn.fnamemodify(node.path, ':h')
            require('toggleterm.terminal').Terminal:new({ dir = path, direction = 'horizontal' }):toggle()
          end,
        },
      },
    },
    trevy_changes = {
      repos_root = vim.fn.expand('~/code/trevy'),
      repo_glob = '*/.git',
      bind_to_cwd = false,
      hide_root_node = true,
      window = {
        mappings = {
          ['<cr>'] = 'open_diffview',
          ['l'] = 'open_diffview',
          ['o'] = 'open_diffview',
          ['p'] = 'toggle_preview',
          ['h'] = 'close_node',
          ['\\'] = 'close_window',
          ['R'] = 'refresh',
          ['D'] = 'open_repo_diff',
        },
      },
    },
  },
}
