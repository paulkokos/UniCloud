-- UniCloud Java Debug Configuration for AstroNvim
-- Place this file in your AstroNvim user config or source it from init.lua

return {
  -- DAP (Debug Adapter Protocol) configuration
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config = function()
      local dap = require("dap")

      -- Java Debug Adapter Configuration
      dap.adapters.java = {
        type = "server",
        host = "localhost",
        port = 5005,
      }

      -- Java Debug Configurations
      dap.configurations.java = {
        -- Attach to running UniCloud Backend
        {
          type = "java",
          request = "attach",
          name = "Attach to UniCloud Backend",
          hostName = "localhost",
          port = 5005,
          projectName = "unicloud-backend",
        },

        -- Attach with auto-restart
        {
          type = "java",
          request = "attach",
          name = "Attach to UniCloud (Auto-restart)",
          hostName = "localhost",
          port = 5005,
          projectName = "unicloud-backend",
          restart = true,
        },

        -- Debug specific test
        {
          type = "java",
          request = "launch",
          name = "Debug Current Test",
          mainClass = "${file}",
          projectName = "unicloud-backend",
          cwd = "${workspaceFolder}",
          classPaths = { "target/test-classes", "target/classes" },
        },
      }

      -- Optional: Set up signs for breakpoints
      vim.fn.sign_define("DapBreakpoint", {
        text = "🔴",
        texthl = "DiagnosticError",
        linehl = "",
        numhl = ""
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "🟡",
        texthl = "DiagnosticWarn",
        linehl = "",
        numhl = ""
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "⭕",
        texthl = "DiagnosticInfo",
        linehl = "",
        numhl = ""
      })
      vim.fn.sign_define("DapStopped", {
        text = "▶️",
        texthl = "DiagnosticOk",
        linehl = "DapStoppedLine",
        numhl = ""
      })
      vim.fn.sign_define("DapLogPoint", {
        text = "📝",
        texthl = "DiagnosticHint",
        linehl = "",
        numhl = ""
      })
    end,
  },

  -- DAP UI for better debugging experience
  {
    "rcarriga/nvim-dap-ui",
    optional = true,
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
      })

      -- Automatically open/close UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- Virtual text for debugging
  {
    "theHamsta/nvim-dap-virtual-text",
    optional = true,
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        show_stop_reason = true,
        commented = false,
        virt_text_pos = "eol",
      })
    end,
  },
}
