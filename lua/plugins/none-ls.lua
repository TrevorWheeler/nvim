return {
  'nvimtools/none-ls.nvim',
  config = function()
    local null_ls = require 'null-ls'
    null_ls.setup {
      debug = false,
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.diagnostics.golangci_lint,
        null_ls.builtins.formatting.gofumpt,
        null_ls.builtins.completion.spell,
      },
    }

    vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, {})
  end,
}
