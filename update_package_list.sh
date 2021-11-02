#!/usr/bin/env bash
DOTFILE_SRC=$(dirname "${BASH_SOURCE[0]}")
if [ "$DOTFILE_SRC" = "." ]; then
  DOTFILE_SRC=$PWD
fi

pacman -Qqen > $DOTFILE_SRC/pkglist.txt
pacman -Qqem > $DOTFILE_SRC/aur-pkglist.txt
