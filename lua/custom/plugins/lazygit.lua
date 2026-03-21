return {
  "kdheepak/lazygit.nvim",
  lazy = true,
  cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Lazy[G]it" },
    {
      "<leader>gp",
      function()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        local trevy_root = vim.fn.expand("~/code/trevy")
        local repos = {}
        local handle = io.popen('find "' .. trevy_root .. '" -maxdepth 1 -mindepth 1 -type d')
        if not handle then return end
        for path in handle:lines() do
          if vim.fn.isdirectory(path .. "/.git") == 1 then
            table.insert(repos, path)
          end
        end
        handle:close()

        if #repos == 0 then
          vim.notify("No git repos found in " .. trevy_root, vim.log.levels.WARN)
          return
        end

        table.sort(repos)

        pickers.new({}, {
          prompt_title = "Trevy Repos",
          finder = finders.new_table({
            results = repos,
            entry_maker = function(entry)
              local name = vim.fn.fnamemodify(entry, ":t")
              return { value = entry, display = name, ordinal = name }
            end,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              vim.cmd("cd " .. vim.fn.fnameescape(selection.value))
              vim.cmd("LazyGit")
            end)
            return true
          end,
        }):find()
      end,
      desc = "Lazy[G]it [P]roject picker",
    },
  },
}
