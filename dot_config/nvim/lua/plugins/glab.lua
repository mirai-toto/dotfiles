return {
  {
    "mirai-toto/glab.nvim",
    keys = {
      { "<leader>glp", function() require("glab").view_pipeline() end, desc = "Pipeline CI (glab)" },
      { "<leader>glr", function() require("glab").run_pipeline() end, desc = "Run pipeline (glab)" },
    },
  },
}
