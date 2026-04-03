local M = {}

M.STRING = { name = "string", badge = "str", hl = "Comment" }
M.INT = { name = "int", badge = "int", hl = "DiagnosticInfo" }
M.FLOAT = { name = "float", badge = "flt", hl = "DiagnosticInfo" }
M.BOOL = { name = "bool", badge = "bool", hl = "DiagnosticWarn" }
M.ARRAY = { name = "array", badge = "arr", hl = "DiagnosticOk" }

M.TYPES = { M.STRING, M.INT, M.FLOAT, M.BOOL, M.ARRAY }

M.ROW_SCHEMA = {
  { name = "key", type = "string", default = "" },
  { name = "type", type = "TYPE", default = M.STRING },
  { name = "value", type = "string", default = "" },
}

--- Cycles to the next type.
M.cycle = function(current)
  for i, t in ipairs(M.TYPES) do
    if t == current then
      return M.TYPES[(i % #M.TYPES) + 1]
    end
  end
  return M.STRING
end

return M

