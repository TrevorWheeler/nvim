local events = require("neo-tree.events")
local git = require("neo-tree.git")
local manager = require("neo-tree.sources.manager")
local renderer = require("neo-tree.ui.renderer")
local utils = require("neo-tree.utils")

---@class neotree.sources.TrevyChanges : neotree.Source
local M = {
  name = "trevy_changes",
  display_name = " 󰊢 Trevy ",
  commands = require("neo-tree.sources.trevy_changes.commands"),
  components = require("neo-tree.sources.git_status.components"),
}

local status_cache = {}
local cache_ttl_ms = 2000

local function get_state()
  return manager.get_state(M.name)
end

local function get_repo_roots(root, repo_glob)
  local repos = vim.fn.globpath(root, repo_glob, false, true)
  local repo_roots = {}

  for _, git_dir in ipairs(repos) do
    repo_roots[#repo_roots + 1] = vim.fn.fnamemodify(git_dir, ":h")
  end

  table.sort(repo_roots)
  return repo_roots
end

local function now_ms()
  return vim.uv.hrtime() / 1000000
end

local function clear_cache()
  status_cache = {}
end

local function make_virtual_dir(id, name, parent_id, extra)
  return {
    id = id,
    name = name,
    path = id,
    type = "directory",
    loaded = true,
    children = {},
    parent_path = parent_id,
    extra = extra or {},
  }
end

local function make_file_node(path, parent_id, repo_root)
  local repo_relative = path:sub(#repo_root + 2)
  return {
    id = path,
    name = repo_relative,
    path = path,
    type = "file",
    parent_path = parent_id,
    extra = {
      repo_root = repo_root,
    },
  }
end

local function classify_status(status)
  if type(status) == "table" then
    status = status[1]
  end

  if status == "?" then
    return "untracked", "Untracked", 3
  end

  local staged = status:sub(1, 1)
  if staged ~= "." then
    return "staged", "Staged", 1
  end

  return "unstaged", "Unstaged", 2
end

local function ensure_group(parent, groups, repo_root, key, label, order)
  if groups[key] then
    return groups[key]
  end

  local id = repo_root .. "::" .. key
  local group = make_virtual_dir(id, label, parent.id, {
    repo_root = repo_root,
    virtual = true,
    group_order = order,
  })
  groups[key] = group
  table.insert(parent.children, group)
  return group
end

local function add_file_node(parent, file_path, repo_root)
  table.insert(parent.children, make_file_node(file_path, parent.id, repo_root))
end

local function add_status_item(repo_node, repo_root, item_path, status, expanded)
  local stat = vim.uv.fs_stat(item_path)
  if not stat or stat.type ~= "file" then
    return false
  end

  local bucket_key, bucket_label, bucket_order = classify_status(status)
  repo_node._groups = repo_node._groups or {}
  local group = ensure_group(repo_node, repo_node._groups, repo_root, bucket_key, bucket_label, bucket_order)
  expanded[group.id] = true
  add_file_node(group, item_path, repo_root)
  return true
end

local function get_repo_status(repo_root)
  local cached = status_cache[repo_root]
  local current = now_ms()
  if cached and (current - cached.at_ms) < cache_ttl_ms then
    return cached.status_lookup
  end

  local status_lookup = git.status(repo_root, nil, false, {
    ignored = "no",
    untracked_files = "all",
  })

  status_cache[repo_root] = {
    at_ms = current,
    status_lookup = status_lookup,
  }

  return status_lookup
end

local function append_count(node, count)
  node.name = string.format("%s (%d)", node.name, count)
end

local function count_files(node)
  local total = 0
  for _, child in ipairs(node.children or {}) do
    if child.type == "file" then
      total = total + 1
    elseif child.children then
      total = total + count_files(child)
    end
  end
  return total
end

local function add_counts(node)
  if not node.children or #node.children == 0 then
    return 0
  end

  local total = 0
  for _, child in ipairs(node.children) do
    if child.type == "file" then
      total = total + 1
    else
      local child_total = add_counts(child)
      total = total + child_total
      if child_total > 0 and child.extra and child.extra.virtual then
        append_count(child, child_total)
      end
    end
  end

  return total
end

local function sort_nodes(nodes)
  table.sort(nodes, function(a, b)
    local a_order = a.extra and a.extra.group_order
    local b_order = b.extra and b.extra.group_order

    if a_order and b_order and a_order ~= b_order then
      return a_order < b_order
    end

    return a.name:lower() < b.name:lower()
  end)

  for _, node in ipairs(nodes) do
    if node.children and #node.children > 0 then
      sort_nodes(node.children)
    end
  end
end

local function render_empty(root, state, message)
  root.children = {
    {
      id = "trevy_changes_empty",
      name = message,
      type = "message",
    },
  }
  renderer.show_nodes({ root }, state)
end

M.navigate = function(state, path, path_to_reveal, callback, async)
  if state.loading then
    return
  end

  state.loading = true
  state.path = path or state.path or vim.fn.expand(state.repos_root or "~/code/trevy")

  local root = make_virtual_dir(state.path, vim.fn.fnamemodify(state.path, ":t"), nil, {
    repo_root = state.path,
    virtual = true,
  })
  root.search_pattern = state.search_pattern

  local repo_roots = get_repo_roots(state.path, state.repo_glob or "*/.git")
  if #repo_roots == 0 then
    render_empty(root, state, "No git repos found")
    state.loading = false
    if type(callback) == "function" then
      vim.schedule(callback)
    end
    return
  end

  local expanded = { [root.id] = true }
  local has_changes = false

  for _, repo_root in ipairs(repo_roots) do
    local repo_name = vim.fn.fnamemodify(repo_root, ":t")
    local repo_node = make_virtual_dir(repo_root, repo_name, root.id, {
      repo_root = repo_root,
      virtual = true,
    })
    local repo_has_changes = false

    local status_lookup = get_repo_status(repo_root)

    if status_lookup then
      for item_path, status in pairs(status_lookup) do
        if item_path ~= repo_root and utils.is_subpath(repo_root, item_path) then
          local added = add_status_item(repo_node, repo_root, item_path, status, expanded)
          if added then
            has_changes = true
            repo_has_changes = true
          end
        end
      end
    end

    if repo_has_changes then
      table.insert(root.children, repo_node)
      expanded[repo_node.id] = true
    end
  end

  if has_changes then
    add_counts(root)
    state.default_expanded_nodes = vim.tbl_keys(expanded)
    sort_nodes(root.children)
    renderer.show_nodes({ root }, state)
  else
    state.default_expanded_nodes = vim.tbl_keys(expanded)
    render_empty(root, state, "No changes across trevy repos")
  end

  state.loading = false

  if type(callback) == "function" then
    vim.schedule(callback)
  end
end

---@class (exact) neotree.Config.TrevyChanges : neotree.Config.Source
---@field repos_root string?
---@field repo_glob string?

M.setup = function(config, global_config)
  if config.before_render then
    manager.subscribe(M.name, {
      event = events.BEFORE_RENDER,
      handler = function(state)
        local this_state = get_state()
        if state == this_state then
          config.before_render(this_state)
        end
      end,
    })
  end

  if global_config.enable_refresh_on_write then
    manager.subscribe(M.name, {
      event = events.VIM_BUFFER_CHANGED,
      handler = function(args)
        if utils.is_real_file(args.afile) then
          manager.refresh(M.name)
        end
      end,
    })
  end

  manager.subscribe(M.name, {
    event = events.GIT_EVENT,
    handler = function()
      clear_cache()
      manager.refresh(M.name)
    end,
  })

  manager.subscribe(M.name, {
    event = events.VIM_DIR_CHANGED,
    handler = function()
      local state = get_state()
      state.path = vim.fn.expand(config.repos_root or "~/code/trevy")
      clear_cache()
      manager.refresh(M.name)
    end,
  })

  manager.subscribe(M.name, {
    event = events.FS_EVENT,
    handler = function(args)
      local changed_path = args and args.afile or ""
      local repos_root = vim.fn.expand(config.repos_root or "~/code/trevy")
      if changed_path ~= "" and utils.is_subpath(repos_root, changed_path) then
        clear_cache()
        manager.refresh(M.name)
      end
    end,
  })

  manager.subscribe(M.name, {
    event = events.VIM_BUFFER_CHANGED,
    handler = function()
      clear_cache()
    end,
  })
end

return M
