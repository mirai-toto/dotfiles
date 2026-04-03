local M = {}

M.view_pipeline = function()
  Snacks.terminal("glab ci view")
end

M.run_pipeline = function()
  require("glab.run").open()
end

return M
