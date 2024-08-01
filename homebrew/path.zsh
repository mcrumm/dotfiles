export PATH="/opt/homebrew/bin:$PATH"

# Load all completions for Homebrew packages
if type brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi
