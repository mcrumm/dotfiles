#!/bin/sh
#
# Elixir
#
# This installs runtimes for Erlang and Elixir.

if ! type mise &>/dev/null; then
  echo "mise must be installed in order to install Elixir"
  exit 1
fi

# Bring in the kerl environment variables
source $ZSH/elixir/kerl.zsh

echo "> mise use --global erlang@latest"
mise use --global erlang@latest

echo "> mise use --global elixir@latest"
mise use --global elixir@latest
