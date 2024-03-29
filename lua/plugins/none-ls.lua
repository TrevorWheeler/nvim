return {
  'nvimtools/none-ls.nvim',
  config = function()
    local null_ls = require 'null-ls'
    null_ls.setup {
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.completion.spell,
        null_ls.builtins.code_actions.eslint,
        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.code_actions.impl,
        null_ls.builtins.code_actions.gomodifytags,
        null_ls.builtins.completion.luasnip,
        null_ls.builtins.completion.vsnip,
        null_ls.builtins.diagnostics.tsc,
      },
    }

    vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, {})
  end,
}
