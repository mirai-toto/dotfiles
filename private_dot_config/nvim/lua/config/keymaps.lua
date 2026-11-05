-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>sp", function()
  require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Search and Replace (current file)" })

vim.keymap.set("v", "<leader>sp", function()
  require("grug-far").with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Search and Replace (current file)" })

-- vim.keymap.set("x", "p", "P", { desc = "Paste without overwriting register" })

vim.keymap.del("n", "<leader>gl")
