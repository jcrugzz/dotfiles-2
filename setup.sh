#!/usr/bin/env bash
DOTFILE_SRC=$(dirname "${BASH_SOURCE[0]}")
if [ "$DOTFILE_SRC" = "." ]; then
  DOTFILE_SRC=$PWD
fi

echo Script source: $DOTFILE_SRC

if which dpkg >> /dev/null; then
  sudo dpkg -i $DOTFILE_SRC/deb_pkgs/*
fi

if docker ps 2>&1 >> /dev/null; then
  docker import $DOTFILE_SRC/deb_pkgs/vim.tar
fi

setup_vim () {
  mkdir -p $HOME/.vim
  if [ -L $HOME/.vim/coc-settings.json ]; then
    echo "${HOME}/.vim/coc-settings.json exists!"
  else
    echo "Removing ${HOME}/.vim/coc-settings.json}"
    rm -f $HOME/.vim/coc-settings.json
    echo "Linking $PWD/coc-settings.json to ${HOME}/.vim/coc-settings.json"
    ln -s $PWD/coc-settings.json $HOME/.vim/coc-settings.json
  fi

}

setup_dotfiles () {
  for DOTFILE in $(find $DOTFILE_SRC -type f -name ".*"); do
    FN=$(basename $DOTFILE) 
    if [ -L $HOME/$FN ]; then
      echo "${HOME}/${FN} exists!"
    else
      echo "Removing ${HOME}/${FN}"
      rm -f $HOME/$FN
      echo "Linking ${DOTFILE} to ${HOME}/${FN}"
      ln -s $DOTFILE $HOME/$FN
    fi
  done
}

setup_dotfiles
setup_vim
