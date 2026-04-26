#!/usr/bin/env bash
#
# Install caddy reverse proxy for SABnzbd.

set -e

PLIST_NAME="net.crumm.caddy-sabnzbd"
PLIST_SRC="$(cd "$(dirname "$0")" && pwd)/${PLIST_NAME}.plist"
PLIST_DST="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"

# Sign caddy binary so macOS firewall allows local network access
CADDY_BIN="$(which caddy 2>/dev/null || echo /usr/local/bin/caddy)"
if [ -x "$CADDY_BIN" ]; then
  echo "  Signing ${CADDY_BIN} for macOS firewall..."
  sudo codesign --force --sign - "$CADDY_BIN"
fi

# Unload existing service if loaded
if launchctl list "$PLIST_NAME" &>/dev/null; then
  echo "  Unloading existing ${PLIST_NAME}..."
  launchctl unload "$PLIST_DST" 2>/dev/null || true
fi

# Link plist into LaunchAgents
mkdir -p "$HOME/Library/LaunchAgents"
ln -sf "$PLIST_SRC" "$PLIST_DST"

# Load the service
launchctl load "$PLIST_DST"

echo "  SABnzbd proxy running at http://localhost:19080"
