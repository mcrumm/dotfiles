#!/bin/sh
#
# Android SDK (CLI)
#
# Installs Android SDK command-line tools and essential components.
# Requires: brew install --cask android-commandlinetools (via Brewfile)

ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"

if ! command -v sdkmanager &>/dev/null; then
  echo "  sdkmanager not found on PATH"
  echo "  Run: brew install --cask android-commandlinetools"
  exit 1
fi

SDKMANAGER="$(command -v sdkmanager)"

mkdir -p "$ANDROID_HOME"

echo "> Installing Android SDK components to $ANDROID_HOME"

# Accept licenses non-interactively
yes | "$SDKMANAGER" --sdk_root="$ANDROID_HOME" --licenses > /dev/null 2>&1

# Install essential components
"$SDKMANAGER" --sdk_root="$ANDROID_HOME" \
  "cmdline-tools;latest" \
  "platform-tools" \
  "build-tools;35.0.0" \
  "platforms;android-35" \
  "emulator"

echo "  Android SDK installed to $ANDROID_HOME"
echo "  To install additional components: sdkmanager --list"
