return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "[G]it [D]iffview" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "[G]it file [H]istory" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "[G]it branch [H]istory" },
    {
      "<leader>ga",
      function()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local previewers = require("telescope.previewers")

        local trevy_root = vim.fn.expand("~/code/trevy")
        local results = {}

        -- Find all git repos and their changed files
        local repos = vim.fn.globpath(trevy_root, "*/.git", false, true)
        for _, git_dir in ipairs(repos) do
          local repo_path = vim.fn.fnamemodify(git_dir, ":h")
          local repo_name = vim.fn.fnamemodify(repo_path, ":t")
          local status = vim.fn.systemlist("git -C " .. vim.fn.shellescape(repo_path) .. " status --short")
          for _, line in ipairs(status) do
            if line ~= "" then
              local status_code = line:sub(1, 2)
              local file = line:sub(4)
              table.insert(results, {
                repo_name = repo_name,
                repo_path = repo_path,
                status = vim.trim(status_code),
                file = file,
                full_path = repo_path .. "/" .. file,
                display = string.format("%-18s %s %s", repo_name, status_code, file),
              })
            end
          end
        end

        if #results == 0 then
          vim.notify("No changes across trevy repos", vim.log.levels.INFO)
          return
        end

        pickers.new({}, {
          prompt_title = "Trevy Changes (all repos)",
          finder = finders.new_table({
            results = results,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.display,
                ordinal = entry.repo_name .. " " .. entry.file,
                filename = entry.full_path,
              }
            end,
          }),
          sorter = conf.generic_sorter({}),
          previewer = previewers.new_termopen_previewer({
            get_command = function(entry)
              local e = entry.value
              if e.status == "??" then
                return { "cat", e.full_path }
              end
              return { "git", "-C", e.repo_path, "diff", "--", e.file }
            end,
          }),
          attach_mappings = function(prompt_bufnr, map)
            -- Enter opens the file
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              vim.cmd("edit " .. vim.fn.fnameescape(selection.value.full_path))
            end)
            -- Ctrl-d opens diffview for that repo
            map("i", "<C-d>", function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              vim.cmd("cd " .. vim.fn.fnameescape(selection.value.repo_path))
              vim.cmd("DiffviewOpen")
            end)
            map("n", "<C-d>", function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              vim.cmd("cd " .. vim.fn.fnameescape(selection.value.repo_path))
              vim.cmd("DiffviewOpen")
            end)
            return true
          end,
        }):find()
      end,
      desc = "[G]it [A]ll repos changes",
    },
  },
  opts = {},
}
