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
          info = '',
          warn = '',
          error = '',
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
      use_libuv_file_watcher = true,
      renderers = {
        directory = {
          { 'indent' },
          { 'icon' },
          { 'current_filter' },
          {
            'container',
            content = {
              { 'name', zindex = 10 },
              {
                'symlink_target',
                zindex = 10,
                highlight = 'NeoTreeSymbolicLinkTarget',
              },
              { 'clipboard', zindex = 10 },
              { 'diagnostics', errors_only = true, zindex = 20, align = 'right', hide_when_expanded = true },
              { 'git_status', zindex = 10, align = 'right', hide_when_expanded = true },
            },
          },
        },
        file = {
          { 'indent' },
          { 'icon' },
          {
            'container',
            content = {
              { 'name', zindex = 10 },
              {
                'symlink_target',
                zindex = 10,
                highlight = 'NeoTreeSymbolicLinkTarget',
              },
              { 'clipboard', zindex = 10 },
              { 'bufnr', zindex = 10 },
              { 'modified', zindex = 20, align = 'right' },
              { 'diagnostics', zindex = 20, align = 'right' },
              { 'git_status', zindex = 10, align = 'right' },
            },
          },
        },
      },
      components = {
        name = function(config, node, state)
          local highlight = config.highlight or 'NeoTreeFileName'
          local text = node.name

          if node.type == 'directory' then
            highlight = 'NeoTreeDirectoryName'
            if config.trailing_slash and text ~= '/' then
              text = text .. '/'
            end
          end

          if node:get_depth() == 1 and node.type ~= 'message' then
            highlight = 'NeoTreeRootName'
            if state.current_position == 'current' and state.sort and state.sort.label == 'Name' then
              local icon = state.sort.direction == 1 and '▲' or '▼'
              text = text .. '  ' .. icon
            end
          else
            if config.use_filtered_colors then
              local filtered_by = state.components.filtered_by(config, node, state)
              highlight = filtered_by.highlight or highlight
            end
            if config.use_git_status_colors then
              local git_status = state.components.git_status({}, node, state)
              if git_status and git_status.highlight then
                highlight = git_status.highlight
              end
            end
          end

          local diag = state.diagnostics_lookup or {}
          local diag_state = diag[node:get_id()]
          if diag_state and diag_state.severity_string then
            highlight = 'DiagnosticSign' .. diag_state.severity_string
          end

          local hl_opened = config.highlight_opened_files
          local opened_buffers = state.opened_buffers or {}
          if not diag_state and hl_opened then
            if
              (hl_opened == 'all' and opened_buffers[node.path])
              or (opened_buffers[node.path] and opened_buffers[node.path].loaded)
            then
              highlight = 'NeoTreeFileNameOpened'
            end
          end

          if type(config.right_padding) == 'number' and config.right_padding > 0 then
            text = text .. string.rep(' ', config.right_padding)
          end

          return {
            text = text,
            highlight = highlight,
          }
        end,
      },
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
      },
      window = {
        width = 36,
        auto_expand_width = true,
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
      renderers = {
        directory = {
          { 'indent' },
          { 'icon' },
          {
            'container',
            content = {
              { 'name', zindex = 10 },
              { 'git_status', zindex = 10, align = 'right', hide_when_expanded = true },
            },
          },
        },
        file = {
          { 'indent' },
          { 'icon' },
          {
            'container',
            content = {
              { 'name', zindex = 10 },
              { 'git_status', zindex = 10, align = 'right' },
            },
          },
        },
        message = {
          { 'indent', with_markers = false },
          { 'name', highlight = 'NeoTreeMessage' },
        },
      },
      window = {
        width = 36,
        auto_expand_width = true,
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
