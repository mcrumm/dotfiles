#!/bin/sh
#
# Zed
#
# Symlinks Zed settings into ~/.config/zed/

ZED_CONFIG_DIR="$HOME/.config/zed"
DOTFILES_ZED="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$ZED_CONFIG_DIR"

if [ -f "$ZED_CONFIG_DIR/settings.json" ] && [ ! -L "$ZED_CONFIG_DIR/settings.json" ]; then
  echo "  Backing up existing settings.json to settings.json.backup"
  mv "$ZED_CONFIG_DIR/settings.json" "$ZED_CONFIG_DIR/settings.json.backup"
fi

ln -sf "$DOTFILES_ZED/settings.json" "$ZED_CONFIG_DIR/settings.json"
echo "  Linked Zed settings.json"
