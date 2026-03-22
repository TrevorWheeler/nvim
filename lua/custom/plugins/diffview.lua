return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen -- %<cr>", desc = "[G]it [D]iff current file" },
    {
      "<leader>gg",
      function()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local previewers = require("telescope.previewers")
        local entry_display = require("telescope.pickers.entry_display")

        local trevy_root = vim.fn.expand("~/code/trevy")
        local results = {}

        local repos = vim.fn.globpath(trevy_root, "*/.git", false, true)
        for _, git_dir in ipairs(repos) do
          local repo_path = vim.fn.fnamemodify(git_dir, ":h")
          local repo_name = vim.fn.fnamemodify(repo_path, ":t")
          local status = vim.fn.systemlist("git -C " .. vim.fn.shellescape(repo_path) .. " status --porcelain")
          for _, line in ipairs(status) do
            if line ~= "" then
              local index_status = line:sub(1, 1)
              local worktree_status = line:sub(2, 2)
              local file = line:sub(4)

              local stage
              if index_status ~= " " and index_status ~= "?" then
                stage = "staged"
              else
                stage = "unstaged"
              end

              local status_code = vim.trim(line:sub(1, 2))

              table.insert(results, {
                repo_name = repo_name,
                repo_path = repo_path,
                status = status_code,
                stage = stage,
                file = file,
                full_path = repo_path .. "/" .. file,
              })
            end
          end
        end

        if #results == 0 then
          vim.notify("No changes across trevy repos", vim.log.levels.INFO)
          return
        end

        -- Sort: group by repo, then staged before unstaged
        table.sort(results, function(a, b)
          if a.repo_name ~= b.repo_name then return a.repo_name < b.repo_name end
          if a.stage ~= b.stage then return a.stage == "staged" end
          return a.file < b.file
        end)

        local displayer = entry_display.create({
          separator = " ",
          items = {
            { width = 16 },
            { width = 8 },
            { width = 4 },
            { remaining = true },
          },
        })

        pickers.new({}, {
          prompt_title = "Trevy Changes (all repos)",
          finder = finders.new_table({
            results = results,
            entry_maker = function(entry)
              local stage_hl = entry.stage == "staged" and "DiagnosticOk" or "DiagnosticWarn"
              local status_hl = "DiagnosticError"
              if entry.status == "??" then
                status_hl = "DiagnosticHint"
              elseif entry.status == "A" then
                status_hl = "DiagnosticOk"
              elseif entry.status == "D" then
                status_hl = "DiagnosticError"
              end

              return {
                value = entry,
                ordinal = entry.repo_name .. " " .. entry.stage .. " " .. entry.file,
                filename = entry.full_path,
                display = function()
                  return displayer({
                    { entry.repo_name, "TelescopeResultsIdentifier" },
                    { entry.stage, stage_hl },
                    { entry.status, status_hl },
                    { entry.file },
                  })
                end,
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
              if e.stage == "staged" then
                return { "git", "-C", e.repo_path, "diff", "--cached", "--", e.file }
              end
              return { "git", "-C", e.repo_path, "diff", "--", e.file }
            end,
          }),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              local e = selection.value
              vim.cmd("cd " .. vim.fn.fnameescape(e.repo_path))
              vim.cmd("DiffviewOpen -- " .. vim.fn.fnameescape(e.file))
            end)
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
      desc = "[G]it [G]lobal changes",
    },
  },
  opts = {},
}
