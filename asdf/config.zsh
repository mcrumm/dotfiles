if [[ -a $HOME/.asdf/asdf.sh ]]
then
  source "$HOME/.asdf/asdf.sh"
  fpath=("${ASDF_DIR}/completions" $fpath)
fi
