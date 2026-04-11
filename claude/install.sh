#!/bin/sh
#
# Claude Code
#
# Symlinks Claude Code settings into ~/.claude/

CLAUDE_CONFIG_DIR="$HOME/.claude"
DOTFILES_CLAUDE="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$CLAUDE_CONFIG_DIR"

if [ -f "$CLAUDE_CONFIG_DIR/settings.json" ] && [ ! -L "$CLAUDE_CONFIG_DIR/settings.json" ]; then
  echo "  Backing up existing settings.json to settings.json.backup"
  mv "$CLAUDE_CONFIG_DIR/settings.json" "$CLAUDE_CONFIG_DIR/settings.json.backup"
fi

ln -sf "$DOTFILES_CLAUDE/settings.json" "$CLAUDE_CONFIG_DIR/settings.json"
echo "  Linked Claude Code settings.json"
