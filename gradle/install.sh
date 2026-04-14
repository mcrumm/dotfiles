#!/bin/sh
#
# Gradle
#
# Symlinks Gradle properties into ~/.gradle/

GRADLE_DIR="$HOME/.gradle"
DOTFILES_GRADLE="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$GRADLE_DIR"

if [ -f "$GRADLE_DIR/gradle.properties" ] && [ ! -L "$GRADLE_DIR/gradle.properties" ]; then
  echo "  Backing up existing gradle.properties to gradle.properties.backup"
  mv "$GRADLE_DIR/gradle.properties" "$GRADLE_DIR/gradle.properties.backup"
fi

ln -sf "$DOTFILES_GRADLE/gradle.properties" "$GRADLE_DIR/gradle.properties"
echo "  Linked Gradle properties"
