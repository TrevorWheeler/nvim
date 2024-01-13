return {
  'goolord/alpha-nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },

  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    dashboard.section.header.val = {}

    dashboard.section.buttons.val = {
      dashboard.button('e', '  > New File', '<cmd>ene<CR>'),
      dashboard.button('ctrl + r', '󰄉  > Recent Files'),
      dashboard.button('ctrl + p', '  > Find File'),
      dashboard.button('ctrl g', '󰱼  > Live Grep'),
      dashboard.button('q', '󰅚  > Quit', '<Cmd>qa<CR>'),
    }
    _Gopts = {
      position = 'center',
      hl = 'Type',
    }

    local plugins = #vim.tbl_keys(require('lazy').plugins())
    local function meta()
      local v = vim.version()
      local datetime = os.date ' %d-%m-%Y   %H:%M:%S'
      local platform = vim.fn.has 'win32' == 1 and '' or ''
      return string.format('󰂖 %d plugins  %s %d.%d.%d  %s', plugins, platform, v.major, v.minor, v.patch, datetime)
    end

    dashboard.section.footer.val = {
      meta()
    }
    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)

  end,
}
