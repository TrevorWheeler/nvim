local M = {}

local function is_diffview_tab()
  local ok, lib = pcall(require, "diffview.lib")
  if not ok then
    return false
  end

  return lib.tabpage_to_view(vim.api.nvim_get_current_tabpage()) ~= nil
end

function M.cmd_abbrev()
  local line = vim.fn.getcmdline()
  if vim.fn.getcmdtype() ~= ":" then
    return line
  end

  if not is_diffview_tab() then
    return line
  end

  if line == "q" or line == "quit" or line == "q!" or line == "quit!" then
    return "DiffviewClose"
  end

  return line
end

return M
