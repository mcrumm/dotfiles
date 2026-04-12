#!/bin/sh
#
# LOVE2D
#
# Downloads and installs LOVE2D from GitHub releases,
# then creates a symlink at /usr/local/bin/love.

LOVE_VERSION="11.5"
LOVE_APP="/Applications/love.app"
LOVE_BIN="/usr/local/bin/love"

LOVE_ZIP="love-${LOVE_VERSION}-macos.zip"
LOVE_URL="https://github.com/love2d/love/releases/download/${LOVE_VERSION}/${LOVE_ZIP}"

# Skip if already installed at the correct version
if [ -x "$LOVE_BIN" ] && "$LOVE_BIN" --version 2>&1 | grep -q "$LOVE_VERSION"; then
  echo "  LOVE2D $LOVE_VERSION already installed"
  exit 0
fi

echo "  Downloading LOVE2D $LOVE_VERSION"
curl -sL -o "/tmp/${LOVE_ZIP}" "$LOVE_URL"

echo "  Installing love.app to /Applications"
unzip -oq "/tmp/${LOVE_ZIP}" -d /tmp/love2d-install
mv /tmp/love2d-install/love.app "$LOVE_APP"
rm -rf /tmp/love2d-install "/tmp/${LOVE_ZIP}"

# Remove macOS quarantine flag
xattr -d com.apple.quarantine "$LOVE_APP" 2>/dev/null || true

echo "  Creating symlink at $LOVE_BIN"
sudo mkdir -p /usr/local/bin
sudo ln -sf "$LOVE_APP/Contents/MacOS/love" "$LOVE_BIN"

echo "  Installed LOVE2D $LOVE_VERSION"
