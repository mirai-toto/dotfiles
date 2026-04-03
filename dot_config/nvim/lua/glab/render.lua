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
  local key_str = pad(row:display("key"), COL_WIDTHS.key)
  local type_str = pad(row:display("type"), COL_WIDTHS.type)
  local value_str = pad(row:display("value"), COL_WIDTHS.value)

  if is_active then
    if cursor_col == 1 then
      key_str = "[" .. pad(row:display("key"), COL_WIDTHS.key - 2) .. "]"
    end
    if cursor_col == 2 then
      type_str = "[" .. pad(row:display("type"), COL_WIDTHS.type - 2) .. "]"
    end
    if cursor_col == 3 then
      value_str = "[" .. pad(row:display("value"), COL_WIDTHS.value - 2) .. "]"
    end
  end

  return string.format("  %s  %s  %s", key_str, type_str, value_str)
end

-- Precomputed column byte offsets for highlights
local KEY_START   = 2
local KEY_END     = KEY_START + COL_WIDTHS.key
local TYPE_START  = KEY_END + 2
local TYPE_END    = TYPE_START + COL_WIDTHS.type
local VALUE_START = TYPE_END + 2
local VALUE_END   = VALUE_START + COL_WIDTHS.value
local SEP_WIDTH   = VALUE_END + 2

M.WIDTH = SEP_WIDTH + 4

-- ─── Highlight one data row ──────────────────────────────────────────────────

local function highlight_row(buf, line, row, is_active, cursor_col)
  local hl_key = is_active and cursor_col == 1 and "CursorLine" or "Normal"
  local hl_type = is_active and cursor_col == 2 and "CursorLine" or row.type.hl
  local hl_value = is_active and cursor_col == 3 and "CursorLine" or "Normal"

  vim.api.nvim_buf_set_extmark(buf, NS, line, KEY_START, { end_col = KEY_END, hl_group = hl_key })
  vim.api.nvim_buf_set_extmark(buf, NS, line, TYPE_START, { end_col = TYPE_END, hl_group = hl_type })
  vim.api.nvim_buf_set_extmark(buf, NS, line, VALUE_START, { end_col = VALUE_END, hl_group = hl_value })
end

-- ─── Main render ─────────────────────────────────────────────────────────────

M.render = function()
  local S = form.STATE
  if not vim.api.nvim_buf_is_valid(S.buf) then
    return
  end

  vim.bo[S.buf].modifiable = true
  vim.api.nvim_buf_clear_namespace(S.buf, NS, 0, -1)

  local sep = string.rep("─", SEP_WIDTH)
  local lines = {}

  table.insert(lines, make_header())
  table.insert(lines, sep)

  for i, row in ipairs(S.rows) do
    table.insert(lines, make_row_line(row, S.cursor.row == i, S.cursor.col))
  end

  table.insert(lines, sep)
  table.insert(lines, "  $ " .. utils.build_cmd(S.branch, S.rows))
  table.insert(lines, "")
  table.insert(lines, "  <a> add  <d> del  <Tab> next col  <CR> edit  <r> run  <q> quit")

  vim.api.nvim_buf_set_lines(S.buf, 0, -1, false, lines)

  -- Header + separators
  vim.api.nvim_buf_set_extmark(S.buf, NS, 0, 0, { end_row = 0, hl_group = "Comment", hl_eol = true })
  vim.api.nvim_buf_set_extmark(S.buf, NS, 1, 0, { end_row = 1, hl_group = "Comment", hl_eol = true })

  -- Data rows
  for i, row in ipairs(S.rows) do
    highlight_row(S.buf, i + 1, row, S.cursor.row == i, S.cursor.col)
  end

  -- Bottom
  local sep_line = #S.rows + 2
  vim.api.nvim_buf_set_extmark(S.buf, NS, sep_line, 0, { end_row = sep_line, hl_group = "Comment", hl_eol = true })
  vim.api.nvim_buf_set_extmark(
    S.buf,
    NS,
    sep_line + 1,
    0,
    { end_row = sep_line + 1, hl_group = "Special", hl_eol = true }
  )
  vim.api.nvim_buf_set_extmark(
    S.buf,
    NS,
    sep_line + 3,
    0,
    { end_row = sep_line + 3, hl_group = "Comment", hl_eol = true }
  )

  vim.bo[S.buf].modifiable = false

  if vim.api.nvim_win_is_valid(S.win) then
    local col_offsets = { KEY_START, TYPE_START, VALUE_START }
    vim.api.nvim_win_set_cursor(S.win, { S.cursor.row + 2, col_offsets[S.cursor.col] })
  end
end

return M
