#!/bin/sh
#
# Visual Studio Code
#
# Symlinks VS Code settings into ~/Library/Application Support/Code/User/

VSCODE_CONFIG_DIR="$HOME/Library/Application Support/Code/User"
DOTFILES_VSCODE="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$VSCODE_CONFIG_DIR"

if [ -f "$VSCODE_CONFIG_DIR/settings.json" ] && [ ! -L "$VSCODE_CONFIG_DIR/settings.json" ]; then
  echo "  Backing up existing settings.json to settings.json.backup"
  mv "$VSCODE_CONFIG_DIR/settings.json" "$VSCODE_CONFIG_DIR/settings.json.backup"
fi

ln -sf "$DOTFILES_VSCODE/settings.json" "$VSCODE_CONFIG_DIR/settings.json"
echo "  Linked VS Code settings.json"
