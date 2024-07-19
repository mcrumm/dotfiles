#!/bin/sh
#
# Elixir
#
# This installs runtimes for Erlang and Elixir.

if [[ -a $HOME/.asdf/asdf.sh ]]; then
  # Source asdf so we can check for installed runtimes.
  source "$HOME/.asdf/asdf.sh"
fi

if ! type asdf &>/dev/null; then
  echo "asdf must be installed in order to install Elixir"
  exit 1
fi

# Bring in the kerl environment variables
source $ZSH/elixir/kerl.zsh

echo "> asdf plugin add erlang"
asdf plugin add erlang

echo "> asdf plugin add elixir"
asdf plugin add elixir

echo "> asdf install erlang latest"
asdf install erlang latest

echo "> asdf install elixir latest"
asdf install elixir latest

asdf global erlang latest
asdf global elixir latest
