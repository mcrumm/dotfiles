#!/bin/sh
#
# ASDF
#
# This installs the asdf runtime version manager.

echo "› asdf install"

if ! [ -d $HOME/.asdf ]; then
  git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.14.0
fi
