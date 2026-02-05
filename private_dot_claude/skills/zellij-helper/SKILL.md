---
name: zellij-helper
description: |
  This skill should be used when the user mentions Zellij, terminal multiplexer, zellij commands, or asks about sessions, panes, layouts, or tabs in Zellij. Provides guidance on Zellij session management, layouts, pane operations, and configuration.
version: 1.0.0
---

# Zellij Helper Agent

## What's New in Zellij 2025 (v0.42-0.43)

- **Web Client**: Built-in web server for browser access with authentication tokens
- **Stacked Resize**: Auto-stack panes when resizing for better space management
- **Pinned Floating Panes**: Keep floating panes always-on-top with toggle
- **Multiple Pane Selection**: Alt+click or Alt+p to select and operate on multiple panes
- **Session Resurrection**: Automatic serialization and resume after crash/reboot
- **New Themes**: ao, vesper, night-owl, iceberg, onedark, lucario

## Overview

Zellij is a modern terminal multiplexer with a focus on user experience, WebAssembly plugins, and KDL-based configuration. It provides sessions, tabs, and panes for organizing terminal workflows, with layouts for reproducible workspace setups.

## CLI Commands

### Session Management

```bash
# Start new session
zellij

# Start named session
zellij -s my-session

# Start with layout
zellij --layout dev

# List sessions
zellij list-sessions
zellij ls

# Attach to session
zellij attach my-session
zellij a my-session

# Attach or create if doesn't exist
zellij attach -c my-session

# Kill session
zellij kill-session my-session
zellij k my-session

# Kill all sessions
zellij kill-all-sessions
zellij ka

# Delete session (remove from resurrection)
zellij delete-session my-session
zellij d my-session

# Delete all sessions
zellij delete-all-sessions
zellij da
```

### Setup Commands

```bash
# Validate configuration
zellij setup --check

# Dump default config
zellij setup --dump-config > config.kdl

# Dump specific layout
zellij setup --dump-layout default

# Generate shell completions
zellij setup --generate-completion bash
zellij setup --generate-completion zsh
zellij setup --generate-completion fish

# Generate autostart script
zellij setup --generate-auto-start bash
```

### Zellij Run

Run commands in new panes from the shell:

```bash
# Run command in new pane
zellij run -- htop

# Run in floating pane
zellij run -f -- npm run dev

# Run in specific direction
zellij run -d right -- tail -f /var/log/syslog

# Close pane on command exit
zellij run -c -- make build

# Run in-place (replace current pane)
zellij run -i -- vim file.txt

# Start suspended (press Enter to run)
zellij run -s -- dangerous-command

# Custom pane name
zellij run -n "Build Output" -- cargo build

# Set working directory
zellij run --cwd /path/to/project -- ls -la

# Floating pane with size and position
zellij run -f --width 50% --height 30 -x 10% -y 5 -- htop
```

### Zellij Edit

Open files in editor panes:

```bash
# Open file in $EDITOR
zellij edit file.txt

# Open at specific line
zellij edit --line-number 42 src/main.rs

# Open in floating pane
zellij edit -f config.yaml

# Open in-place
zellij edit -i notes.md

# With direction
zellij edit -d down Makefile
```

## Actions

Use `zellij action <action-name>` to control Zellij programmatically. Actions cover pane operations (create, close, move, resize, toggle fullscreen/floating), tab operations (create, close, navigate, rename, break pane to tab), navigation (focus panes, scroll), session control (detach, quit, switch mode), and plugin management.

See `references/actions-reference.md` for the full list of actions and their CLI usage.

## Layouts

Layouts are KDL files (stored in `~/.config/zellij/layouts/`) that define tab and pane arrangements. They support split directions, commands with arguments, working directories, floating panes, stacked panes, tab templates, and session configuration. Load with `zellij --layout <name>` or `zellij action new-tab -l <name>`.

See `references/layouts.md` for layout file format, floating/stacked pane syntax, and session configuration.

## Configuration

Config lives at `~/.config/zellij/config.kdl`. Key options include shell/editor defaults, mouse/copy behavior, themes, scrollback, session serialization, and web client settings (v0.43+). Keybindings are configured per-mode in a `keybinds` block.

See `references/configuration.md` for all config options, keybindings, modes, and plugin configuration.

## Modes

Zellij has 13 input modes: `normal`, `locked`, `pane`, `tab`, `resize`, `move`, `scroll`, `search`, `entersearch`, `renametab`, `renamepane`, `session`, and `tmux`. Switch modes with keybindings (default: Ctrl+g for locked, Ctrl+p for pane, Ctrl+t for tab, etc.).

See `references/configuration.md` for the full modes table and keybinding details.

## When to Ask for Help

Ask the user for clarification when:
- Session name is ambiguous or conflicts with existing
- Layout file location or format is unclear
- Keybinding customization needs specifics
- Plugin paths or configuration need verification
- Destructive operations (kill-all-sessions) need confirmation
- Web client security configuration is required

## Additional Resources

For detailed reference material beyond the core commands above, see:

- `references/actions-reference.md` - All `zellij action` commands and action tables (pane, tab, navigation, session operations)
- `references/layouts.md` - Layout file format (KDL), floating panes, stacked panes, session configuration
- `references/configuration.md` - Config options, keybindings, modes, plugins (built-in, external, community)
- `references/examples.md` - Common workflows, shell integration, IDE-like layout, scripted setup, web client, troubleshooting
