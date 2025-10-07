# UniCloud Configuration Files

This directory contains IDE and editor configurations for the UniCloud project.

## Directory Structure

```
.config/
├── nvim/             # Neovim/AstroNvim configurations
└── ide/              # IDE-specific configurations
    ├── vscode/       # VS Code configurations
    └── intellij/     # IntelliJ IDEA run configurations
```

## Neovim Configuration (`nvim/`)

AstroNvim debug configurations for Java development.

**Files:**
- `dap-config.lua` - Debug Adapter Protocol configuration
- `keymaps.lua` - Debug keybindings
- `astronvim-config.lua` - Complete AstroNvim user config

**Setup:**
```bash
# Copy to AstroNvim config directory
cp nvim/astronvim-config.lua ~/.config/nvim/lua/user/init.lua

# Or merge specific parts as needed
```

**Documentation:** See `docs/debugging/NVIM-DEBUG.md`

## VS Code Configuration (`ide/vscode/`)

VS Code workspace and debug configurations.

**Files:**
- `launch.json` - Debug configurations
- `settings.json` - Workspace settings (if present)
- `tasks.json` - Build tasks (if present)

**Setup:**
- Configurations are automatically detected when opening the project in VS Code
- Additional setup: See `docs/debugging/DEBUG.md`

## IntelliJ IDEA Configuration (`ide/intellij/`)

IntelliJ IDEA run and debug configurations.

**Files:**
- `UniCloud_Backend_Debug.xml` - Remote debug configuration
- `UniCloud_Backend_Run.xml` - Run configuration

**Setup:**
- Configurations are automatically imported when opening the project
- Located in `.idea/runConfigurations/` (if IDEA is used)
- Additional setup: See `docs/debugging/DEBUG.md`

## Eclipse Configuration

Eclipse users can use the remote debug configuration:

1. Run → Debug Configurations → Remote Java Application
2. Create new configuration:
   - Project: `unicloud-backend`
   - Host: `localhost`
   - Port: `5005`

See `docs/debugging/DEBUG.md` for details.

## Editor-Agnostic Configurations

These files work across all editors:

### Checkstyle
- Location: `../checkstyle.xml`
- Standard: Google Java Style with customizations
- Line length: 120 characters

### EditorConfig
Create `.editorconfig` in root for consistent formatting:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.java]
indent_style = space
indent_size = 2

[*.{yml,yaml}]
indent_style = space
indent_size = 2

[*.xml]
indent_style = space
indent_size = 2

[*.sh]
indent_style = space
indent_size = 2
```

## Adding Your Configuration

If you use a different editor/IDE:

1. Create a subdirectory: `.config/ide/your-editor/`
2. Add your configuration files
3. Document the setup in this README
4. Consider adding to `.gitignore` if it contains personal settings

## Configuration Priority

When multiple configurations exist:

1. **Project-level** (this directory) - Shared across team
2. **User-level** (`~/.config/`, `~/.vscode/`, etc.) - Personal preferences
3. **Global** (IDE defaults) - Fallback

Project-level configurations in this directory should be:
- Generic and portable
- Not contain personal paths or credentials
- Checked into version control (except sensitive data)

## Ignore Patterns

Some IDE files should NOT be committed:

```gitignore
# IntelliJ
.idea/workspace.xml
.idea/tasks.xml
.idea/dictionaries/
.idea/shelf/

# VS Code
.vscode/settings.json  # If contains personal settings

# Eclipse
.metadata/
.recommenders/
```

Our `.gitignore` already handles most of these.

## Best Practices

1. **Share generic configurations** - Commit team-wide settings
2. **Keep personal settings local** - Don't commit personal preferences
3. **Document setup** - Update this README when adding configs
4. **Test portability** - Ensure configs work on different machines
5. **Version control** - Track configuration changes in git

## Troubleshooting

### IntelliJ not loading run configurations

```bash
# Check if files exist
ls -la .config/ide/intellij/

# Restart IntelliJ IDEA
# File → Invalidate Caches / Restart
```

### VS Code not finding launch.json

```bash
# Ensure correct location
ls -la .config/ide/vscode/launch.json

# VS Code expects it in .vscode/ at project root
# Create symlink if needed:
ln -s .config/ide/vscode .vscode
```

### Neovim configs not working

```bash
# Ensure files are in correct location
ls -la ~/.config/nvim/lua/user/

# Check for syntax errors
nvim --headless -c "luafile ~/.config/nvim/lua/user/init.lua" -c q
```

## Related Documentation

- **Debugging Guide:** `../docs/debugging/DEBUG.md`
- **Neovim Debug Guide:** `../docs/debugging/NVIM-DEBUG.md`
- **Main README:** `../README.md`
