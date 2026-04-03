local types = require("glab.types")

local M = {}

M.STATE = {
  buf = nil,
  win = nil,
  rows = {},
  cursor = { row = 1, col = 1 },
  branch = nil,
}

local COLS = 3

-- ─── Row ─────────────────────────────────────────────────────────────────────

M.new_row = function()
  return { key = "", type = "string", value = "" }
end

M.col_name = function(col)
  return ({ "key", "type", "value" })[col]
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
  if col > COLS then
    col = 1
    M.STATE.cursor.row = math.min(M.STATE.cursor.row + 1, #M.STATE.rows)
  elseif col < 1 then
    col = COLS
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
    row.type = types.cycle(row.type)
  end
end

M.set_field = function(value)
  local row = M.STATE.rows[M.STATE.cursor.row]
  local field = M.col_name(M.STATE.cursor.col)
  if row and field and value ~= nil then
    row[field] = value
  end
end

M.current_row = function()
  return M.STATE.rows[M.STATE.cursor.row]
end

return M
