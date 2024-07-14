#!/bin/sh
#
# ASDF
#
# This installs the asdf runtime version manager.

echo "› asdf install"

if ! [ -d $HOME/.asdf ]; then
  git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.14.0
fi

if [[ -a $HOME/.asdf/asdf.sh ]]; then
  # Source asdf so we can check for installed runtimes.
  source "$HOME/.asdf/asdf.sh"

  asdf_plugins=$(asdf plugin-list)
  want_plugins=(erlang elixir)

  for p in ${want_plugins[@]}; do
    echo "> asdf plugin add $p"
    if ! [[ $asdf_plugins =~ $p ]]; then
      asdf plugin add $p
    fi
  done
fi
