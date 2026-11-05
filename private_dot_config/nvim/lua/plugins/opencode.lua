return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  config = true,
  keys = {
    { "<leader>o", nil, desc = "AI/OpenCode" },
    {
      "<leader>oc",
      function()
        require("opencode").select()
      end,
      desc = "OpenCode select",
    },
    {
      "<leader>oa",
      function()
        require("opencode").ask("@this: ")
      end,
      mode = { "n", "x" },
      desc = "Ask OpenCode",
    },
    {
      "<leader>op",
      function()
        require("opencode").prompt("")
      end,
      desc = "Prompt OpenCode",
    },
    {
      "<leader>os",
      function()
        require("opencode").prompt("@this ")
      end,
      mode = "v",
      desc = "Send to OpenCode",
    },
    {
      "<leader>ob",
      function()
        require("opencode").prompt("@buffer ")
      end,
      desc = "Send buffer to OpenCode",
    },
    {
      "<leader>od",
      function()
        require("opencode").prompt("@diagnostics ")
      end,
      desc = "Send diagnostics to OpenCode",
    },
    -- Session management
    {
      "<leader>on",
      function()
        require("opencode").command("session.new")
      end,
      desc = "New session",
    },
    {
      "<leader>oi",
      function()
        require("opencode").command("session.interrupt")
      end,
      desc = "Interrupt session",
    },
    {
      "<leader>ou",
      function()
        require("opencode").command("session.undo")
      end,
      desc = "Undo",
    },
    {
      "<leader>or",
      function()
        require("opencode").command("session.redo")
      end,
      desc = "Redo",
    },
  },
}
