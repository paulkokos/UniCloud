-- UniCloud Debug Keymaps for AstroNvim
-- Add these to your AstroNvim mappings configuration

return {
  n = {
    -- Debug Controls
    ["<F5>"] = { function() require("dap").continue() end, desc = "Debug: Start/Continue" },
    ["<F10>"] = { function() require("dap").step_over() end, desc = "Debug: Step Over" },
    ["<F11>"] = { function() require("dap").step_into() end, desc = "Debug: Step Into" },
    ["<F12>"] = { function() require("dap").step_out() end, desc = "Debug: Step Out" },

    -- Breakpoints
    ["<leader>db"] = { function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    ["<leader>dB"] = {
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Conditional Breakpoint"
    },
    ["<leader>dL"] = {
      function()
        require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end,
      desc = "Log Point"
    },
    ["<leader>dc"] = { function() require("dap").clear_breakpoints() end, desc = "Clear All Breakpoints" },

    -- Debug Sessions
    ["<leader>dr"] = { function() require("dap").repl.open() end, desc = "Open REPL" },
    ["<leader>dl"] = { function() require("dap").run_last() end, desc = "Run Last Debug Config" },
    ["<leader>dt"] = { function() require("dap").terminate() end, desc = "Terminate Debug Session" },
    ["<leader>dR"] = { function() require("dap").restart() end, desc = "Restart Debug Session" },

    -- DAP UI
    ["<leader>du"] = { function() require("dapui").toggle() end, desc = "Toggle Debug UI" },
    ["<leader>de"] = { function() require("dapui").eval() end, desc = "Evaluate Expression" },
    ["<leader>dh"] = { function() require("dap.ui.widgets").hover() end, desc = "Debug Hover" },

    -- UniCloud Specific
    ["<leader>dU"] = {
      function()
        -- Start UniCloud backend with debug
        vim.fn.system("./start-backend-debug.sh &")
        vim.notify("Starting UniCloud backend with debug...", vim.log.levels.INFO)
        -- Wait 10 seconds then attach
        vim.defer_fn(function()
          require("dap").continue()
          vim.notify("Attached to UniCloud backend", vim.log.levels.INFO)
        end, 10000)
      end,
      desc = "Start & Debug UniCloud Backend"
    },
    ["<leader>dT"] = {
      function()
        -- Run tests with debug
        local test_file = vim.fn.expand("%:t:r")
        vim.fn.system("mvn test -Dtest=" .. test_file .. " -Dmaven.surefire.debug &")
        vim.notify("Starting test with debug: " .. test_file, vim.log.levels.INFO)
        -- Wait 5 seconds then attach
        vim.defer_fn(function()
          require("dap").continue()
          vim.notify("Attached to test", vim.log.levels.INFO)
        end, 5000)
      end,
      desc = "Debug Current Test File"
    },
  },

  -- Visual mode mappings
  v = {
    ["<leader>de"] = { function() require("dapui").eval() end, desc = "Evaluate Selection" },
  },
}
