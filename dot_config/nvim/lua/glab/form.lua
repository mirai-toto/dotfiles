local types = require("glab.types")

local M = {}

M.STATE = {
  buf = nil,
  win = nil,
  rows = {},
  cursor = { row = 1, col = 1 },
  branch = nil,
}

-- ─── Row class ───────────────────────────────────────────────────────────────

local Row = {}
Row.__index = Row

function Row.new()
  local self = setmetatable({}, Row)
  for _, col in ipairs(types.ROW_SCHEMA) do
    self[col.name] = col.default
  end
  return self
end

--- Returns the display string for a field (badge for type, raw value otherwise).
function Row:display(field)
  if field == "type" then
    return self.type.badge
  end
  return self[field] or ""
end

function Row:set(field, value)
  self[field] = value
end

-- ─── Public API ──────────────────────────────────────────────────────────────

M.new_row = function()
  return Row.new()
end

M.col_name = function(col)
  return types.ROW_SCHEMA[col] and types.ROW_SCHEMA[col].name
end

M.col_type = function(col)
  return types.ROW_SCHEMA[col] and types.ROW_SCHEMA[col].type
end

-- ─── Mutations ───────────────────────────────────────────────────────────────

M.reset = function(branch)
  M.STATE.branch = branch
  M.STATE.rows = { M.new_row() }
  M.STATE.cursor = { row = 1, col = 1 }
  M.STATE.buf = nil
  M.STATE.win = nil
end

M.add_row = function()
  table.insert(M.STATE.rows, M.new_row())
  M.STATE.cursor.row = #M.STATE.rows
  M.STATE.cursor.col = 1
end

M.delete_row = function()
  if #M.STATE.rows == 0 then
    return
  end
  table.remove(M.STATE.rows, M.STATE.cursor.row)
  if M.STATE.cursor.row > #M.STATE.rows then
    M.STATE.cursor.row = math.max(1, #M.STATE.rows)
  end
end

M.move_cursor = function(direction)
  local col = M.STATE.cursor.col + direction
  if col > #types.ROW_SCHEMA then
    col = 1
    M.STATE.cursor.row = math.min(M.STATE.cursor.row + 1, #M.STATE.rows)
  elseif col < 1 then
    col = #types.ROW_SCHEMA
    M.STATE.cursor.row = math.max(M.STATE.cursor.row - 1, 1)
  end
  M.STATE.cursor.col = col
end

M.move_row = function(direction)
  M.STATE.cursor.row = math.max(1, math.min(M.STATE.cursor.row + direction, #M.STATE.rows))
end

M.cycle_type = function()
  local row = M.STATE.rows[M.STATE.cursor.row]
  if row then
    row:set("type", types.cycle(row.type))
  end
end

M.set_field = function(value)
  local row = M.STATE.rows[M.STATE.cursor.row]
  local field = M.col_name(M.STATE.cursor.col)
  if row and field and value ~= nil then
    row:set(field, value)
  end
end

M.current_row = function()
  return M.STATE.rows[M.STATE.cursor.row]
end

return M

