return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gl", group = "GitLab" },
      },
    },
  },
  {
    "harrisoncramer/gitlab.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "MunifTanjim/nui.nvim",
      "stevearc/dressing.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    build = function()
      require("gitlab.server").build(true)
    end,
    opts = {
      gitlab_url = os.getenv("GITLAB_URL"),
      auth_token = os.getenv("GITLAB_TOKEN"),
      connection_settings = {
        proxy = os.getenv("HTTPS_PROXY"),
        remote = "origin",
      },
    },
    keys = {
      { "<leader>glr", "<cmd>lua require('gitlab').review()<cr>", desc = "Review" },
      { "<leader>gls", "<cmd>lua require('gitlab').summary()<cr>", desc = "Summary" },
      { "<leader>gla", "<cmd>lua require('gitlab').approve()<cr>", desc = "Approve" },
      { "<leader>glo", "<cmd>lua require('gitlab').open_in_browser()<cr>", desc = "Open in Browser" },
      { "<leader>glm", "<cmd>lua require('gitlab').merge()<cr>", desc = "Merge" },
      { "<leader>glp", "<cmd>lua require('gitlab').pipeline()<cr>", desc = "Pipeline" },
    },
  },
}
