#!/bin/sh
#
# Lua
#
# This installs the Lua runtime and LuaRocks.

if ! type mise &>/dev/null; then
  echo "mise must be installed in order to install Lua"
  exit 1
fi

echo "> mise use --global lua@latest"
mise use --global lua@latest
