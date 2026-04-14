#!/bin/sh
#
# Java
#
# This installs the Temurin 21 LTS JDK via mise.

if ! type mise &>/dev/null; then
  echo "mise must be installed in order to install Java"
  exit 1
fi

echo "> mise use --global java@temurin-21"
mise use --global java@temurin-21
