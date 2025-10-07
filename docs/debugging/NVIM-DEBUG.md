# AstroNvim Debug Setup for UniCloud

## Installation

### 1. Install Required Plugins

Add to your AstroNvim configuration (`~/.config/nvim/lua/user/plugins/`):

```lua
-- File: ~/.config/nvim/lua/user/plugins/dap.lua
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-telescope/telescope-dap.nvim",
  },
}
```

### 2. Copy Configuration Files

```bash
# From UniCloud project root:
cp .nvim/astronvim-config.lua ~/.config/nvim/lua/user/init.lua

# Or manually merge the configuration
```

### 3. Install Plugins

Open Neovim and run:
```vim
:Lazy sync
```

## Quick Start

### Method 1: Attach to Running Backend

```bash
# Terminal 1: Start backend with debug
./start-backend-debug.sh

# Terminal 2: Open Neovim
nvim

# In Neovim: Press F5 or :lua require('dap').continue()
# Select: "Attach to UniCloud Backend (Port 5005)"
```

### Method 2: Debug from Neovim

```bash
# Open Neovim in project
cd /home/paulkokos/MyProjects/UniCloud
nvim

# In Neovim:
# 1. Open a Java file (e.g., UserController.java)
# 2. Set breakpoint: <leader>db
# 3. Start debug: F5
```

## Keybindings

### Debug Controls (F-keys)

| Key | Action |
|-----|--------|
| `F5` | Continue / Start debugging |
| `F10` | Step over |
| `F11` | Step into |
| `F12` | Step out |

### Breakpoints (Leader + d)

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Clear all breakpoints |
| `<leader>dS` | List all breakpoints (Telescope) |

### Debug Session (Leader + d)

| Key | Action |
|-----|--------|
| `<leader>du` | Toggle debug UI |
| `<leader>dr` | Open REPL |
| `<leader>dt` | Terminate session |
| `<leader>dR` | Restart session |
| `<leader>ds` | Show stack frames (Telescope) |
| `<leader>dv` | Show variables (Telescope) |
| `<leader>dC` | DAP commands (Telescope) |

### Evaluation

| Key | Action | Mode |
|-----|--------|------|
| `<leader>de` | Evaluate expression under cursor | Normal |
| `<leader>de` | Evaluate selected code | Visual |

## Workflow Examples

### Example 1: Debug REST Endpoint

```bash
# 1. Start backend with debug
./start-backend-debug.sh

# 2. Open Neovim
nvim unicloud-backend/src/main/java/com/unicloud/backend/controller/UserController.java

# 3. Navigate to line with @PostMapping
# 4. Set breakpoint: <leader>db

# 5. Start debugger: F5
# 6. Select "Attach to UniCloud Backend"

# 7. In another terminal, make API call:
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@test.com","password":"pass"}'

# Neovim will stop at your breakpoint!
# Use F10/F11/F12 to step through code
```

### Example 2: Debug Unit Test

```bash
# 1. Open test file
nvim unicloud-backend/src/test/java/com/unicloud/backend/service/UserServiceTest.java

# 2. Set breakpoint in test method: <leader>db

# 3. Run test with debug (in terminal):
mvn test -Dtest=UserServiceTest#testCreateUser_Success -Dmaven.surefire.debug

# 4. In Neovim: F5 to attach
# Test will pause at breakpoint
```

### Example 3: Debug Application Startup

```bash
# 1. Open main application class
nvim unicloud-backend/src/main/java/com/unicloud/backend/UniCloudBackendApplication.java

# 2. Set breakpoint in main() or @Bean methods: <leader>db

# 3. Start with suspend (waits for debugger):
./start-backend-debug-suspend.sh

# 4. In Neovim: F5 to attach
# Application will start and pause at breakpoint
```

## Debug UI Layout

When you start debugging (`F5`), you'll see:

```
┌─────────────────────┬──────────────────────────────────────┐
│ SCOPES              │                                      │
│ - Local variables   │                                      │
│ - Arguments         │        CODE WINDOW                   │
│                     │                                      │
├─────────────────────┤                                      │
│ BREAKPOINTS         │                                      │
│ - List of all BPs   │                                      │
│                     │                                      │
├─────────────────────┤                                      │
│ STACK TRACE         │                                      │
│ - Call stack        │                                      │
│                     │                                      │
├─────────────────────┤                                      │
│ WATCHES             │                                      │
│ - Watch expressions │                                      │
│                     │                                      │
├─────────────────────┴──────────────────────────────────────┤
│ REPL / CONSOLE                                             │
│ - Execute code                                             │
│ - View output                                              │
└────────────────────────────────────────────────────────────┘
```

## Advanced Features

### Conditional Breakpoints

```vim
# Set cursor on line
# Press <leader>dB
# Enter condition: userId > 100
```

### Log Points

```vim
# Set cursor on line
# Press <leader>dL
# Enter message: User created: {username}
```

### Evaluate Expressions

```vim
# In normal mode:
# 1. Put cursor on variable
# 2. Press <leader>de

# In visual mode:
# 1. Select expression
# 2. Press <leader>de
```

### Watch Variables

```vim
# In debug session:
# 1. Open watches: :lua require('dapui').open()
# 2. Navigate to watches panel
# 3. Add watch: Type variable name
```

## Telescope Integration

Use Telescope for quick navigation:

```vim
# Show all breakpoints
<leader>dS

# Show stack frames
<leader>ds

# Show variables
<leader>dv

# Show DAP commands
<leader>dC
```

## Troubleshooting

### DAP not working

```vim
# Check DAP status
:lua require('dap').status()

# Check if connected
:lua print(vim.inspect(require('dap').session()))
```

### Can't connect to port 5005

```bash
# Check if backend is running with debug
lsof -i :5005

# If not, start backend:
./start-backend-debug.sh
```

### Breakpoints not hitting

1. Ensure code is compiled: `mvn clean compile`
2. Restart backend
3. Clear and reset breakpoints: `<leader>dc` then `<leader>db`

### UI not showing

```vim
# Manually open UI
<leader>du

# Or in command mode:
:lua require('dapui').open()
```

## Configuration Files Reference

All configuration files are in `.nvim/`:
- `dap-config.lua` - Core DAP configuration
- `keymaps.lua` - Keybinding definitions
- `astronvim-config.lua` - Complete AstroNvim config

## Tips & Tricks

### 1. Quick Debug Current File

```vim
# Add this to your config for quick file debugging
map <leader>dF :lua require('dap').run_last()<CR>
```

### 2. Save Debug Session

```vim
# Save breakpoints
:lua require('dap.breakpoints').save()

# Load breakpoints
:lua require('dap.breakpoints').load()
```

### 3. Multiple Debug Sessions

DAP supports multiple sessions. Use `:DapContinue` to start new session.

### 4. Remote Debugging

To debug on remote server:
```bash
# On server
ssh -R 5005:localhost:5005 server

# Start backend on server with debug
# Connect from local Neovim with F5
```

## Resources

- [nvim-dap Documentation](https://github.com/mfussenegger/nvim-dap)
- [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)
- [AstroNvim Documentation](https://astronvim.com)
- [Java Debug Protocol](https://docs.oracle.com/javase/8/docs/technotes/guides/jpda/)

## Quick Reference Card

```
╔═══════════════════════════════════════════════════════╗
║           UniCloud Neovim Debug Shortcuts             ║
╠═══════════════════════════════════════════════════════╣
║ F5          │ Start/Continue debugging                ║
║ F10         │ Step over                               ║
║ F11         │ Step into                               ║
║ F12         │ Step out                                ║
║─────────────┼──────────────────────────────────────────║
║ <leader>db  │ Toggle breakpoint                       ║
║ <leader>dB  │ Conditional breakpoint                  ║
║ <leader>dc  │ Clear all breakpoints                   ║
║─────────────┼──────────────────────────────────────────║
║ <leader>du  │ Toggle debug UI                         ║
║ <leader>dt  │ Terminate session                       ║
║ <leader>dr  │ Open REPL                               ║
║ <leader>de  │ Evaluate expression                     ║
╚═══════════════════════════════════════════════════════╝
```
