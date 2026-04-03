local types = require("glab.types")
local form = require("glab.form")
local utils = require("glab.utils")

local M = {}

local NS = vim.api.nvim_create_namespace("glab_pipeline_run")

local COL_WIDTHS = { key = 20, type = 8, value = 22 }

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function pad(str, len)
  str = str or ""
  if #str >= len then
    return str:sub(1, len)
  end
  return str .. string.rep(" ", len - #str)
end

local function make_header()
  return string.format(
    "  %-" .. COL_WIDTHS.key .. "s  " .. "%-" .. COL_WIDTHS.type .. "s  " .. "%-" .. COL_WIDTHS.value .. "s",
    "key",
    "type",
    "value"
  )
end

local function make_row_line(row, is_active, cursor_col)
  local key_str = pad(row.key, COL_WIDTHS.key)
  local type_str = pad(types.BADGES[row.type] or row.type, COL_WIDTHS.type)
  local value_str = pad(row.value, COL_WIDTHS.value)

  if is_active then
    if cursor_col == 1 then
      key_str = "[" .. pad(row.key, COL_WIDTHS.key - 2) .. "]"
    end
    if cursor_col == 2 then
      type_str = "[" .. pad(types.BADGES[row.type] or row.type, COL_WIDTHS.type - 2) .. "]"
    end
    if cursor_col == 3 then
      value_str = "[" .. pad(row.value, COL_WIDTHS.value - 2) .. "]"
    end
  end

  return string.format("  %s  %s  %s", key_str, type_str, value_str)
end

-- ─── Column byte offsets (for highlights) ────────────────────────────────────

local function col_ranges()
  local key_start = 2
  local key_end = key_start + COL_WIDTHS.key + 2
  local type_start = key_end + 2
  local type_end = type_start + COL_WIDTHS.type + 2
  local value_start = type_end + 2
  local value_end = value_start + COL_WIDTHS.value + 2
  return key_start, key_end, type_start, type_end, value_start, value_end
end

-- ─── Highlight one data row ──────────────────────────────────────────────────

local function highlight_row(buf, line, row, is_active, cursor_col)
  local key_start, key_end, type_start, type_end, value_start, value_end = col_ranges()

  local hl_key = is_active and cursor_col == 1 and "CursorLine" or "Normal"
  local hl_type = is_active and cursor_col == 2 and "CursorLine" or types.HIGHLIGHTS[row.type] or "Comment"
  local hl_value = is_active and cursor_col == 3 and "CursorLine" or "Normal"

  vim.api.nvim_buf_add_highlight(buf, NS, hl_key, line, key_start, key_end)
  vim.api.nvim_buf_add_highlight(buf, NS, hl_type, line, type_start, type_end)
  vim.api.nvim_buf_add_highlight(buf, NS, hl_value, line, value_start, value_end)
end

-- ─── Main render ─────────────────────────────────────────────────────────────

M.render = function()
  local S = form.STATE
  if not vim.api.nvim_buf_is_valid(S.buf) then
    return
  end

  vim.api.nvim_buf_set_option(S.buf, "modifiable", true)
  vim.api.nvim_buf_clear_namespace(S.buf, NS, 0, -1)

  local lines = {}

  table.insert(lines, make_header())
  table.insert(lines, string.rep("─", 58))

  for i, row in ipairs(S.rows) do
    local is_active = S.cursor.row == i
    table.insert(lines, make_row_line(row, is_active, S.cursor.col))
  end

  table.insert(lines, string.rep("─", 58))
  table.insert(lines, "  $ " .. utils.build_cmd(S.branch, S.rows))
  table.insert(lines, "")
  table.insert(lines, "  <a> add  <d> del  <Tab> next col  <CR> edit  <r> run  <q> quit")

  vim.api.nvim_buf_set_lines(S.buf, 0, -1, false, lines)

  -- Header + separators
  vim.api.nvim_buf_add_highlight(S.buf, NS, "Comment", 0, 0, -1)
  vim.api.nvim_buf_add_highlight(S.buf, NS, "Comment", 1, 0, -1)

  -- Data rows
  for i, row in ipairs(S.rows) do
    highlight_row(S.buf, i + 1, row, S.cursor.row == i, S.cursor.col)
  end

  -- Bottom
  local sep_line = #S.rows + 2
  vim.api.nvim_buf_add_highlight(S.buf, NS, "Comment", sep_line, 0, -1)
  vim.api.nvim_buf_add_highlight(S.buf, NS, "Special", sep_line + 1, 0, -1)
  vim.api.nvim_buf_add_highlight(S.buf, NS, "Comment", sep_line + 3, 0, -1)

  vim.api.nvim_buf_set_option(S.buf, "modifiable", false)

  if vim.api.nvim_win_is_valid(S.win) then
    vim.api.nvim_win_set_cursor(S.win, { S.cursor.row + 1, 0 })
  end
end

return M
