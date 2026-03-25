local Preview = require("neo-tree.sources.common.preview")

local M = {}

local function relpath(base, path)
  if vim.fs and vim.fs.relpath then
    return vim.fs.relpath(base, path)
  end

  local prefix = base .. "/"
  if vim.startswith(path, prefix) then
    return path:sub(#prefix + 1)
  end

  return nil
end

local function get_state()
  vim.t.trevy_changes_preview = vim.t.trevy_changes_preview or {
    enabled = false,
    augroup = nil,
    buf_cache = {},
  }
  return vim.t.trevy_changes_preview
end

local function set_buf_lines(bufnr, lines)
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
end

local function ensure_preview_buffer(cache_key)
  local state = get_state()
  local bufnr = state.buf_cache[cache_key]
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    return bufnr
  end

  bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].filetype = "diff"
  state.buf_cache[cache_key] = bufnr
  return bufnr
end

local function file_preview_lines(path)
  local ok, lines = pcall(vim.fn.readfile, path, "", 400)
  if not ok then
    return {
      "Could not read file:",
      path,
    }
  end
  return lines
end

local function diff_preview_lines(repo_root, path, status)
  local relative = relpath(repo_root, path)
  if not relative then
    return {
      "Could not derive repo-relative path:",
      path,
    }
  end

  local lines = {
    string.format("File: %s", relative),
    string.format("Repo: %s", vim.fn.fnamemodify(repo_root, ":t")),
    "",
  }

  if status == "?" then
    vim.list_extend(lines, file_preview_lines(path))
    return lines
  end

  local staged = status:sub(1, 1) ~= "."
  local unstaged = status:sub(2, 2) ~= "."

  if unstaged then
    vim.list_extend(lines, { "Unstaged", "" })
    vim.list_extend(lines, vim.fn.systemlist({ "git", "-C", repo_root, "diff", "--", relative }))
    vim.list_extend(lines, { "", "" })
  end

  if staged then
    vim.list_extend(lines, { "Staged", "" })
    vim.list_extend(lines, vim.fn.systemlist({ "git", "-C", repo_root, "diff", "--cached", "--", relative }))
  end

  if not staged and not unstaged then
    vim.list_extend(lines, { "No diff available" })
  end

  return lines
end

local function ensure_node_preview_buffer(node)
  if not node then
    return nil
  end

  local extra = node.extra or {}
  local cache_key = "node:" .. node:get_id()
  local bufnr = ensure_preview_buffer(cache_key)
  local lines

  if node.type == "file" then
    local repo_root = extra.repo_root
    if not repo_root then
      lines = {
        "Could not determine repo root.",
        node.path or node.name,
      }
    else
      local status = require("neo-tree.git").find_existing_status_code(node.path)
      if type(status) == "table" then
        status = status[1]
      end
      lines = diff_preview_lines(repo_root, node.path, status or "")
    end
  else
    lines = {
      node.name,
      "",
      "Move to a file to preview its diff.",
    }
  end

  set_buf_lines(bufnr, lines)
  extra.bufnr = bufnr
  node.extra = extra
  return bufnr
end

function M.preview_current(state)
  if not state or not state.tree then
    return
  end

  local node = state.tree:get_node()
  if not node or node.type == "message" then
    return
  end

  ensure_node_preview_buffer(node)
  local preview_state = vim.tbl_extend("force", {}, state, {
    config = {
      use_float = false,
      title = "Trevy Diff Preview",
    },
  })
  Preview.show(preview_state)
end

function M.enable_live(state)
  local preview_state = get_state()
  preview_state.enabled = true

  if preview_state.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, preview_state.augroup)
  end

  preview_state.augroup = vim.api.nvim_create_augroup("TrevyChangesPreview", { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = preview_state.augroup,
    buffer = state.bufnr,
    callback = function()
      M.preview_current(state)
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = preview_state.augroup,
    pattern = tostring(state.winid),
    callback = function()
      M.disable()
    end,
  })
  vim.api.nvim_create_autocmd({ "BufHidden", "BufWipeout" }, {
    group = preview_state.augroup,
    buffer = state.bufnr,
    callback = function()
      M.disable()
    end,
  })

  M.preview_current(state)
end

function M.disable()
  local preview_state = get_state()
  preview_state.enabled = false
  if preview_state.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, preview_state.augroup)
    preview_state.augroup = nil
  end
  Preview.hide()
end

function M.focus_first_file(state)
  if not state or not state.tree then
    return nil
  end

  local renderer = require("neo-tree.ui.renderer")

  local function find_first_file(parent_id)
    for _, node in ipairs(state.tree:get_nodes(parent_id)) do
      if node.type == "file" then
        return node:get_id()
      end
      if node:has_children() then
        local child_id = find_first_file(node:get_id())
        if child_id then
          return child_id
        end
      end
    end
  end

  local first_file = find_first_file(nil)
  if not first_file then
    return nil
  end

  renderer.focus_node(state, first_file)
  return first_file
end

return M
