return {
  { "dart-lang/dart-vim-plugin" },

  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = function()
      require("flutter-tools").setup({
        hot_reload_on_save = true,
        dev_log = {
          enabled = true,
          open_on_run = true,
          width = 60,
        },
        lsp = {
          color = { enabled = true },
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
          },
        },
      }      )

      local reload_timer = nil

      local function find_cmux_workspace(name)
        local output = vim.fn.system("cmux find-window " .. vim.fn.shellescape(name) .. " 2>/dev/null")
        if vim.v.shell_error ~= 0 then return nil end
        return output:match("(workspace:%d+)")
      end

      local function find_cmux_surface(workspace_ref, surface_title)
        local tree = vim.fn.system("cmux tree --workspace " .. workspace_ref .. " 2>/dev/null")
        if vim.v.shell_error ~= 0 then return nil end
        for line in tree:gmatch("[^\n]+") do
          local surface_ref = line:match("(surface:%d+)")
          if surface_ref and line:find(surface_title, 1, true) then
            return surface_ref
          end
        end
        return nil
      end

      local function trigger_trevy_reload()
        local path = vim.fn.expand('%:p')
        if path == "" then return end

        if string.find(path, "trevy") then
          if reload_timer then
            reload_timer:stop()
          end

          reload_timer = vim.defer_fn(function()
            vim.schedule(function()
              local workspace = find_cmux_workspace("trevy-mobile")
              if not workspace then
                vim.notify("Trevy: trevy-mobile workspace not found", vim.log.levels.WARN)
                reload_timer = nil
                return
              end
              local surface = find_cmux_surface(workspace, "flutter-run")
              if surface then
                vim.fn.system("cmux send --workspace " .. workspace .. " --surface " .. surface .. " r")
                vim.notify("Trevy: Hot Reloading...", vim.log.levels.INFO)
              else
                vim.notify("Trevy: flutter-run surface not found", vim.log.levels.WARN)
              end
              reload_timer = nil
            end)
          end, 200)
        end
      end

      vim.api.nvim_create_autocmd({ "BufWritePost", "FileChangedShellPost" }, {
        group = vim.api.nvim_create_augroup("TrevyAutoReload", { clear = true }),
        pattern = "*.dart",
        callback = trigger_trevy_reload,
      })

      -- local flutter_run = require('custom.flutter-run')

      -- local k = vim.keymap
      -- k.set("n", "<leader>fr", function() flutter_run.run() end, { desc = "Flutter [R]un" })
      -- k.set("n", "<leader>fq", ":FlutterQuit<CR>", { desc = "Flutter [Q]uit" })
      -- k.set("n", "<leader>fR", ":FlutterRestart<CR>", { desc = "Flutter [R]estart" })
      -- k.set("n", "<leader>fd", ":FlutterDevices<CR>", { desc = "Flutter [D]evices" })
      -- k.set("n", "<leader>fo", ":FlutterOutlineToggle<CR>", { desc = "Flutter [O]utline" })
      -- k.set("n", "<leader>fl", ":FlutterLogToggle<CR>", { desc = "Flutter [L]og Toggle" })
    end,
  },
}
