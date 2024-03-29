return {
  {
    'folke/noice.nvim',
    dependencies = {},
    event = 'VeryLazy',
    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      routes = {
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+L, %d+B' },
              { find = '; after #%d+' },
              { find = '; before #%d+' },
            },
          },
          view = 'mini',
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
    keys = {
      {
        '<S-Enter>',
        function()
          require('noice').redirect(vim.fn.getcmdline())
        end,
        mode = 'c',
        desc = 'Redirect Cmdline',
      },
      {
        '<leader>h',
        function()
          require('noice').cmd 'history'
        end,
        desc = 'Noice History',
      },
    },
    notify = {
      enabled = true,
    },
  },
  {
    'rcarriga/nvim-notify',
    enabled = true,
    config = function()
      require('notify').setup {
        background_colour = '#000000',
      }
    end,
  },

  -- {
  --   'hrsh7th/nvim-cmp',
  --   dependencies = {
  --     'hrsh7th/cmp-buffer',
  --     'hrsh7th/cmp-cmdline',
  --     'hrsh7th/cmp-path',
  --   },
  -- },
}
