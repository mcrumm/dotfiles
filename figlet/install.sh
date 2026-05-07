#!/bin/sh
#
# figlet
#
# Clones the xero/figlet-fonts pack to ~/.figlet-fonts and symlinks
# its .flf/.tlf fonts into figlet's system font directory.

set -e

if ! command -v figlet >/dev/null 2>&1; then
  echo "  figlet not installed; skipping font setup"
  exit 0
fi

FONTS_REPO="$HOME/.figlet-fonts"
FONTS_DIR="$(figlet -I2)"

if [ ! -d "$FONTS_REPO" ]; then
  echo "  Cloning figlet-fonts to $FONTS_REPO"
  git clone --depth=1 https://github.com/xero/figlet-fonts.git "$FONTS_REPO"
fi

echo "  Linking fonts into $FONTS_DIR"
for f in "$FONTS_REPO"/*.flf "$FONTS_REPO"/*.tlf; do
  [ -e "$f" ] || continue
  ln -sf "$f" "$FONTS_DIR/$(basename "$f")"
done
