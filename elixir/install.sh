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
DOTFILES_ELIXIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_ELIXIR/kerl.zsh"

echo "> mise use --global erlang@latest"
mise use --global erlang@latest

echo "> mise use --global elixir@latest"
mise use --global elixir@latest
