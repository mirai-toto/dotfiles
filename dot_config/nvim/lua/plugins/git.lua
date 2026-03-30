return {
  {
    "harrisoncramer/gitlab.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    build = function()
      require("gitlab.server").build(true)
    end,
    opts = {},
    keys = {
      { "<leader>glr", "<cmd>lua require('gitlab').review()<cr>", desc = "GitLab Review" },
      { "<leader>gls", "<cmd>lua require('gitlab').summary()<cr>", desc = "GitLab MR Summary" },
      { "<leader>gla", "<cmd>lua require('gitlab').approve()<cr>", desc = "GitLab Approve" },
      { "<leader>glp", "<cmd>lua require('gitlab').pipeline()<cr>", desc = "GitLab Pipeline" },
    },
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff View Open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diff View Close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
    },
  },
}

