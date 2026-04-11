#!/bin/sh
#
# Ghostty
#
# Symlinks Ghostty config into ~/.config/ghostty/

GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
DOTFILES_GHOSTTY="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$GHOSTTY_CONFIG_DIR"

if [ -f "$GHOSTTY_CONFIG_DIR/config" ] && [ ! -L "$GHOSTTY_CONFIG_DIR/config" ]; then
  echo "  Backing up existing config to config.backup"
  mv "$GHOSTTY_CONFIG_DIR/config" "$GHOSTTY_CONFIG_DIR/config.backup"
fi

ln -sf "$DOTFILES_GHOSTTY/config" "$GHOSTTY_CONFIG_DIR/config"
echo "  Linked Ghostty config"
