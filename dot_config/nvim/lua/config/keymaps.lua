-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local glab = require("glab")
vim.keymap.set("n", "<leader>glP", glab.view_pipeline, { desc = "Pipeline CI (glab)" })
vim.keymap.set("n", "<leader>glR", glab.run_pipeline, { desc = "Run pipeline (glab)" })
