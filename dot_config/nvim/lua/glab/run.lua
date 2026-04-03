local utils = require("glab.utils")
local form = require("glab.form")
local render = require("glab.render")

local M = {}

-- ─── Actions ─────────────────────────────────────────────────────────────────

local function close()
  if form.STATE.win and vim.api.nvim_win_is_valid(form.STATE.win) then
    vim.api.nvim_win_close(form.STATE.win, true)
  end
  form.STATE.win = nil
  form.STATE.buf = nil
end

local function run_pipeline()
  local cmd = utils.build_cmd(form.STATE.branch, form.STATE.rows)
  close()
  Snacks.terminal(cmd)
end

local function edit_current()
  local row = form.current_row()
  local field = form.col_name(form.STATE.cursor.col)
  if not row or not field then
    return
  end

  if field == "type" then
    form.cycle_type()
    render.render()
    return
  end

  Snacks.input({
    prompt = string.format("%s › %s: ", field, row.key ~= "" and row.key or "new"),
    default = row[field],
  }, function(val)
    form.set_field(val)
    render.render()
  end)
end

-- ─── Keymaps ─────────────────────────────────────────────────────────────────

local function set_keymaps()
  local map = function(key, fn)
    vim.keymap.set("n", key, fn, { buffer = form.STATE.buf, nowait = true, silent = true })
  end

  map("q", close)
  map("<Esc>", close)
  map("r", run_pipeline)
  map("<CR>", edit_current)

  map("a", function()
    form.add_row()
    render.render()
  end)

  map("d", function()
    form.delete_row()
    render.render()
  end)

  map("<Tab>", function()
    form.move_cursor(1)
    render.render()
  end)

  map("<S-Tab>", function()
    form.move_cursor(-1)
    render.render()
  end)

  map("j", function()
    form.move_row(1)
    render.render()
  end)

  map("k", function()
    form.move_row(-1)
    render.render()
  end)
end

-- ─── Open ────────────────────────────────────────────────────────────────────

M.open = function()
  local branch = utils.current_branch()
  if not branch then
    vim.notify("[glab] Not in a git repository", vim.log.levels.ERROR)
    return
  end

  form.reset(branch)

  local width = 62
  local height = 12
  local ui = vim.api.nvim_list_uis()[1]
  local col = math.floor((ui.width - width) / 2)
  local row = math.floor((ui.height - height) / 2)

  form.STATE.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(form.STATE.buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(form.STATE.buf, "filetype", "glab_pipeline")

  form.STATE.win = vim.api.nvim_open_win(form.STATE.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = string.format(" glab ci run · %s ", branch),
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(form.STATE.win, "cursorline", false)
  vim.api.nvim_win_set_option(form.STATE.win, "wrap", false)

  set_keymaps()
  render.render()
end

return M
