#!/bin/sh
#
# NodeJS
#
# This installs runtimes for Node.

if [[ -a $HOME/.asdf/asdf.sh ]]; then
  # Source asdf so we can check for installed runtimes.
  source "$HOME/.asdf/asdf.sh"
fi

if ! type asdf &>/dev/null; then
  echo "asdf must be installed in order to install NodeJS"
  exit 1
fi

echo "> asdf plugin add nodejs"
asdf plugin add nodejs

echo "> asdf install nodejs latest"
asdf install nodejs latest

asdf global nodejs latest
