#!/bin/bash
set -euo pipefail

# Detect mode
MODE=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
[[ "$MODE" == "Dark" ]] && M=mocha || M=latte
THEME_MODE=$([[ "$MODE" == "Dark" ]] && echo dark || echo light)

# Zellij
sed -i '' "s/catppuccin-[a-z]*/catppuccin-$M/" ~/.config/zellij/config.kdl 2>/dev/null || true

# btop (handles both macOS and Linux path formats)
sed -i '' "s/catppuccin_[a-z]*/catppuccin_$M/g" ~/.config/btop/btop.conf 2>/dev/null || true
pkill -USR2 btop 2>/dev/null || true

# starship (only change the palette = line, not the section headers)
sed -i '' "s/^palette = \"catppuccin_[a-z]*\"/palette = \"catppuccin_$M\"/" ~/.config/starship.toml 2>/dev/null || true

# fzf + difftastic (fish env vars)
THEME_FILE=~/.config/fish/conf.d/theme-env.fish
mkdir -p "$(dirname "$THEME_FILE")"
if [[ "$M" == "mocha" ]]; then
  cat > "$THEME_FILE" << 'EOF'
set -gx FZF_DEFAULT_OPTS "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
set -gx DFT_BACKGROUND dark
EOF
else
  cat > "$THEME_FILE" << 'EOF'
set -gx FZF_DEFAULT_OPTS "--color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39,fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78,marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39"
set -gx DFT_BACKGROUND light
EOF
fi

# Git config (difft + delta)
if [[ "$M" == "mocha" ]]; then
  git config --global diff.external "difft --background=dark"
  git config --global difftool.difftastic.cmd 'difft --background=dark "$LOCAL" "$REMOTE"'
  git config --global delta.dark true
  git config --global delta.syntax-theme "Catppuccin Mocha"
else
  git config --global diff.external "difft --background=light"
  git config --global difftool.difftastic.cmd 'difft --background=light "$LOCAL" "$REMOTE"'
  git config --global delta.dark false
  git config --global delta.syntax-theme "Catppuccin Latte"
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
