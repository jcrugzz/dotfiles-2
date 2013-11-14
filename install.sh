#!/usr/bin/env bash
SUBLIME_USER_DIR=/Library/Application\ Data/Sublime\ Text\ 3/Packages/User

if [[ -d  "$SUBLIME_USER_DIR"]]; then
  ln -s sublime/* $SUBLIME_USER_DIR
fi

for DOTFILE in bash/*; do
  ln -s $DOTFILE ~/.$DOTFILE
done

for PREF in preferences/*; do
  ln -s $PREF ~/Library/Preferences/$pref
done

