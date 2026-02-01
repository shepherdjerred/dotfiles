#!/bin/bash
set -euo pipefail

# Detect mode
MODE=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
[[ "$MODE" == "Dark" ]] && M=mocha || M=latte
THEME_MODE=$([[ "$MODE" == "Dark" ]] && echo dark || echo light)

# Zellij
sed -i '' "s/catppuccin-\(latte\|frappe\|macchiato\|mocha\)/catppuccin-$M/" ~/.config/zellij/config.kdl 2>/dev/null || true

# btop (handles both macOS and Linux path formats)
sed -i '' "s/catppuccin_\(latte\|frappe\|macchiato\|mocha\)/catppuccin_$M/g" ~/.config/btop/btop.conf 2>/dev/null || true
pkill -USR2 btop 2>/dev/null || true

# starship (only change the palette = line, not the section headers)
sed -i '' "s/^palette = \"catppuccin_\(latte\|frappe\|macchiato\|mocha\)\"/palette = \"catppuccin_$M\"/" ~/.config/starship.toml 2>/dev/null || true

# Atuin (sed replacement like starship)
sed -i '' "s/catppuccin-\(latte\|frappe\|macchiato\|mocha\)/catppuccin-$M/" ~/.config/atuin/config.toml 2>/dev/null || true

# eza (macOS - symlink theme file)
EZA_DIR=~/Library/"Application Support"/eza
[[ -d "$EZA_DIR" ]] && ln -sf "$EZA_DIR/theme-$M.yml" "$EZA_DIR/theme.yml"

# ov (symlink config file)
OV_DIR=~/.config/ov
[[ -d "$OV_DIR" ]] && ln -sf "$OV_DIR/config-$M.yaml" "$OV_DIR/config.yaml"

# fzf + difftastic + jq + LS_COLORS (fish env vars)
THEME_DIR=~/.config/fish/conf.d
[[ -f "$THEME_DIR/theme-env-$M.fish" ]] && ln -sf "theme-env-$M.fish" "$THEME_DIR/theme-env.fish"

# Git config (difft + delta)
if command -v git &>/dev/null; then
  if [[ "$M" == "mocha" ]]; then
    git config --global diff.external "difft --background=dark" 2>/dev/null || true
    git config --global difftool.difftastic.cmd 'difft --background=dark "$LOCAL" "$REMOTE"' 2>/dev/null || true
    git config --global delta.dark true 2>/dev/null || true
    git config --global delta.syntax-theme "Catppuccin Mocha" 2>/dev/null || true
  else
    git config --global diff.external "difft --background=light" 2>/dev/null || true
    git config --global difftool.difftastic.cmd 'difft --background=light "$LOCAL" "$REMOTE"' 2>/dev/null || true
    git config --global delta.dark false 2>/dev/null || true
    git config --global delta.syntax-theme "Catppuccin Latte" 2>/dev/null || true
  fi
fi

# Claude Code
command -v claude &>/dev/null && claude config set -g theme "$THEME_MODE" 2>/dev/null || true

# Gemini CLI
GEMINI=~/.gemini/settings.json
if [[ -f "$GEMINI" ]] && command -v jq &>/dev/null; then
  THEME=$([[ "$M" == "mocha" ]] && echo "GitHub" || echo "GitHub Light")
  TMP=$(mktemp)
  jq --arg t "$THEME" '.ui.theme = $t' "$GEMINI" > "$TMP" && mv "$TMP" "$GEMINI"
fi
