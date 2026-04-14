-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>sp", function()
  require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Search and Replace (current file)" })

vim.keymap.del("n", "<leader>gl")
local glab = require("glab")
vim.keymap.set("n", "<leader>glp", glab.view_pipeline, { desc = "Pipeline CI (glab)" })
vim.keymap.set("n", "<leader>glr", glab.run_pipeline, { desc = "Run pipeline (glab)" })
