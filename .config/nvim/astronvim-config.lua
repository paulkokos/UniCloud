-- Complete AstroNvim User Configuration for UniCloud Debugging
-- Place this in ~/.config/nvim/lua/user/init.lua or merge with your existing config

return {
  -- Configure core features
  colorscheme = "astrodark",

  -- LSP Configuration
  lsp = {
    config = {
      jdtls = {
        settings = {
          java = {
            configuration = {
              runtimes = {
                {
                  name = "JavaSE-17",
                  path = "/usr/lib/jvm/java-17-openjdk-amd64",
                  default = true,
                },
              },
            },
            format = {
              enabled = true,
              settings = {
                url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
              },
            },
            project = {
              referencedLibraries = {
                "lib/**/*.jar",
                "**/target/dependency/*.jar",
              },
            },
          },
        },
      },
    },
  },

  -- Plugins configuration
  plugins = {
    -- DAP (Debug Adapter Protocol)
    {
      "mfussenegger/nvim-dap",
      dependencies = {
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
        "nvim-telescope/telescope-dap.nvim",
      },
      config = function()
        local dap = require("dap")

        -- Java Debug Adapter
        dap.adapters.java = {
          type = "server",
          host = "localhost",
          port = 5005,
        }

        -- Java Configurations
        dap.configurations.java = {
          {
            type = "java",
            request = "attach",
            name = "Attach to UniCloud Backend (Port 5005)",
            hostName = "localhost",
            port = 5005,
            projectName = "unicloud-backend",
          },
          {
            type = "java",
            request = "attach",
            name = "Attach to Test Debug (Port 5005)",
            hostName = "localhost",
            port = 5005,
            projectName = "unicloud-backend",
          },
        }

        -- Breakpoint signs
        vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DiagnosticError" })
        vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DiagnosticWarn" })
        vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DiagnosticOk", linehl = "DapStoppedLine" })
      end,
    },

    -- DAP UI
    {
      "rcarriga/nvim-dap-ui",
      config = function()
        require("dapui").setup({
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

        -- Auto open/close UI
        local dap = require("dap")
        dap.listeners.after.event_initialized["dapui_config"] = function()
          require("dapui").open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          require("dapui").close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          require("dapui").close()
        end
      end,
    },

    -- Virtual text during debugging
    {
      "theHamsta/nvim-dap-virtual-text",
      config = function()
        require("nvim-dap-virtual-text").setup({
          enabled = true,
          highlight_changed_variables = true,
          show_stop_reason = true,
        })
      end,
    },

    -- Telescope integration for DAP
    {
      "nvim-telescope/telescope-dap.nvim",
      config = function()
        require("telescope").load_extension("dap")
      end,
    },
  },

  -- Keymappings
  mappings = {
    n = {
      -- Debug Controls (F-keys)
      ["<F5>"] = { function() require("dap").continue() end, desc = "Debug: Continue" },
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
      ["<leader>dc"] = { function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoints" },

      -- Debug UI
      ["<leader>du"] = { function() require("dapui").toggle() end, desc = "Toggle Debug UI" },
      ["<leader>dr"] = { function() require("dap").repl.open() end, desc = "Open REPL" },
      ["<leader>dt"] = { function() require("dap").terminate() end, desc = "Terminate" },
      ["<leader>dR"] = { function() require("dap").restart() end, desc = "Restart" },

      -- Telescope DAP
      ["<leader>ds"] = { "<cmd>Telescope dap frames<cr>", desc = "DAP Frames" },
      ["<leader>dC"] = { "<cmd>Telescope dap commands<cr>", desc = "DAP Commands" },
      ["<leader>dv"] = { "<cmd>Telescope dap variables<cr>", desc = "DAP Variables" },
      ["<leader>dS"] = { "<cmd>Telescope dap list_breakpoints<cr>", desc = "List Breakpoints" },
    },
    v = {
      ["<leader>de"] = { function() require("dapui").eval() end, desc = "Evaluate Selection" },
    },
  },

  -- Polish function (runs at the very end of setup)
  polish = function()
    -- Set up autocommands
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        vim.notify("Java file detected. Debug available on port 5005", vim.log.levels.INFO)
      end,
    })
  end,
}
