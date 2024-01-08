return {
  'goolord/alpha-nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },

  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    dashboard.section.header.val = {
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                     ]],
      [[       ████ ██████           █████      ██                     ]],
      [[      ███████████             █████                             ]],
      [[      █████████ ███████████████████ ███   ███████████   ]],
      [[     █████████  ███    █████████████ █████ ██████████████   ]],
      [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
      [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
      [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
    }
    local builtin = require 'telescope.builtin'

    dashboard.section.buttons.val = {
      dashboard.button('e', '  > New File', '<cmd>ene<CR>'),
      dashboard.button('SPC fr', '󰄉  > Recent Files'),
      dashboard.button('SPC ff', '  > Find File'),
      dashboard.button('SPC fs', '󰱼  > Find String'),
      dashboard.button('q', '󰅚  > Quit', '<Cmd>qa<CR>'),
    }
    _Gopts = {
      position = 'center',
      hl = 'Type',
      -- wrap = "overflow";
    }

    local function footer()
      local plugins = #vim.tbl_keys(require('lazy').plugins())
      local v = vim.version()
      local datetime = os.date ' %d-%m-%Y   %H:%M:%S'
      local platform = vim.fn.has 'win32' == 1 and '' or ''
      return string.format('󰂖 %d plugins  %s %d.%d.%d  %s', plugins, platform, v.major, v.minor, v.patch, datetime)
    end

    dashboard.section.footer.val = footer()

    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)
  end,
}
