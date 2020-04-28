#!/bin/sh

mkdir -p $HOME/.vim
if [ -L $HOME/.vim/coc-settings.json ]; then
  echo "${HOME}/.vim/coc-settings.json exists!"
else
  rm -f $HOME/.vim/coc-settings.json
  ln -s $PWD/coc-settings.json $HOME/.vim/coc-settings.json
fi

for DOTFILE in $(find $PWD -type f -name ".*"); do
  FN=$(basename $DOTFILE) 
  if [ -L $HOME/$FN ]; then
    echo "${HOME}/${FN} exists!"
  else
    rm -f $HOME/$FN
    ln -s $DOTFILE $HOME/$FN
  fi
done
