local M = {}

M.LIST = { "string", "int", "float", "bool", "array" }

M.BADGES = {
  string = " str ",
  int = " int ",
  float = " flt ",
  bool = " bool",
  array = " arr ",
}

M.HIGHLIGHTS = {
  string = "Comment",
  int = "DiagnosticInfo",
  float = "DiagnosticInfo",
  bool = "DiagnosticWarn",
  array = "DiagnosticOk",
}

--- Cycles to the next type in the list.
---@param current string
---@return string
M.cycle = function(current)
  for i, t in ipairs(M.LIST) do
    if t == current then
      return M.LIST[(i % #M.LIST) + 1]
    end
  end
  return "string"
end

return M
