local M = {}

--- Returns the current git branch name, or nil if not in a git repo.
M.current_branch = function()
  local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
  if branch == "" then
    return nil
  end
  return branch
end

--- Formats a single input entry into a glab --input flag value.
--- string type omits the type wrapper: key:value
--- other types use: key:type(value)
M.format_input = function(key, type, value)
  if key == "" then
    return nil
  end
  if type == "string" or type == "" then
    return string.format("--input %s", vim.fn.shellescape(key .. ":" .. value))
  end
  return string.format("--input %s", vim.fn.shellescape(string.format("%s:%s(%s)", key, type, value)))
end

--- Builds the full glab ci run command from a branch and a list of input rows.
M.build_cmd = function(branch, rows)
  local parts = { "glab ci run", "-b", vim.fn.shellescape(branch) }
  for _, row in ipairs(rows) do
    if row.key and row.key ~= "" then
      local flag = M.format_input(row.key, row.type.name, row.value)
      if flag then
        table.insert(parts, flag)
      end
    end
  end
  return table.concat(parts, " ")
end

return M
