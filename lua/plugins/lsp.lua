return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = false,
    opts = {
      auto_install = true,
    },
  },
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local lspconfig = require 'lspconfig'
      lspconfig.tsserver.setup {
        capabilities = capabilities,
      }
      lspconfig.html.setup {
        capabilities = capabilities,
      }
      lspconfig.lua_ls.setup {
        capabilities = capabilities,
      }
      lspconfig.rust_analyzer.setup {
        -- Server-specific settings. See `:help lspconfig-setup`
        settings = {
          ['rust-analyzer'] = {},
        },
      }
      lspconfig.volar.setup {
        capabilities = capabilities,
        -- init_options = {
        --   typescript = {
        --     tsdk = '/home/trev/.npm/lib/node_modules/typescript/lib',
        --     -- Alternative location if installed as root:
        --     -- tsdk = '/usr/local/lib/node_modules/typescript/lib'
        --   },
        -- },
      }

      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
    end,
  },
}

-- require'lspconfig'.volar.setup{
--   init_options = {
--     typescript = {
--       tsdk = '/path/to/.npm/lib/node_modules/typescript/lib'
--       -- Alternative location if installed as root:
--       -- tsdk = '/usr/local/lib/node_modules/typescript/lib'
--     }
--   }
-- }
