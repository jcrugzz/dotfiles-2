#!/usr/bin/env bash
DOTFILE_SRC=$(dirname "${BASH_SOURCE[0]}")
if [ "$DOTFILE_SRC" = "." ]; then
  DOTFILE_SRC=$PWD
fi

echo Source $DOTFILE_SRC

if which dpkg >> /dev/null; then
  for PKG in ./deb_pkgs; do
    sudo dpkg -i $PKG
  done
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
  vim -es -u vimrc -i NONE -C "PlugInstall" -c "qa"
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
