local cc = require("neo-tree.sources.common.commands")
local git = require("neo-tree.git")
local manager = require("neo-tree.sources.manager")
local utils = require("neo-tree.utils")
local preview = require("custom.trevy_changes_preview")

local M = {}

local function relpath(base, path)
  if vim.fs and vim.fs.relpath then
    return vim.fs.relpath(base, path)
  end

  local prefix = base .. utils.path_separator
  if vim.startswith(path, prefix) then
    return path:sub(#prefix + 1)
  end

  return nil
end

local function open_repo_diff(repo_root, file_path)
  local prev_cwd = vim.fn.getcwd()
  vim.cmd("lcd " .. vim.fn.fnameescape(repo_root))

  local ok, err
  if file_path then
    local relative = relpath(repo_root, file_path)
    if not relative then
      ok = false
      err = "Could not derive repo-relative path for " .. file_path
    else
      ok, err = pcall(vim.cmd, "DiffviewOpen -- " .. vim.fn.fnameescape(relative))
    end
  else
    ok, err = pcall(vim.cmd, "DiffviewOpen")
  end

  vim.cmd("lcd " .. vim.fn.fnameescape(prev_cwd))

  return ok, err
end

M.open = function(state)
  preview.preview_node(state)
end

M.open_diffview = function(state)
  local node = state.tree:get_node()
  if not node or node.type == "message" then
    return
  end

  preview.disable()

  local repo_root = node.extra and node.extra.repo_root or git.find_existing_worktree(node.path)
  if not repo_root then
    vim.notify("Could not determine repo root for " .. node.path, vim.log.levels.ERROR)
    return
  end

  if utils.is_expandable(node) then
    local ok, err = open_repo_diff(repo_root)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
    return
  end

  local status = git.find_existing_status_code(node.path)
  if status == "?" then
    vim.cmd("edit " .. vim.fn.fnameescape(node.path))
    vim.notify("Untracked files open directly because Diffview has no git diff for them", vim.log.levels.INFO)
    return
  end

  local ok, err = open_repo_diff(repo_root, node.path)
  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
  end
end

M.toggle_preview = function(state)
  preview.enable_live(state)
end

M.close_window = function(state)
  preview.disable()
  cc.close_window(state)
end

M.open_repo_diff = function(state)
  local node = state.tree:get_node()
  if not node or node.type == "message" then
    return
  end

  preview.disable()

  local repo_root = node.extra and node.extra.repo_root or git.find_existing_worktree(node.path)
  if not repo_root then
    vim.notify("Could not determine repo root for " .. node.path, vim.log.levels.ERROR)
    return
  end

  local ok, err = open_repo_diff(repo_root)
  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
  end
end

M.refresh = function()
  manager.refresh("trevy_changes")
end

cc._add_common_commands(M)

return M
