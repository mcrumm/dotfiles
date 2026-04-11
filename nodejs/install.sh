#!/bin/sh
#
# NodeJS
#
# This installs runtimes for Node.

if ! type mise &>/dev/null; then
  echo "mise must be installed in order to install NodeJS"
  exit 1
fi

echo "> mise use --global node@latest"
mise use --global node@latest
