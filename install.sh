#!/usr/bin/env bash
SUBLIME_USER_DIR="$HOME/Library/Application Support/Sublime Text 3/Packages/User/"
PREF_PATH=$HOME/Library/Preferences/
CURR_DIR=$(pwd)

if [[ -d  "$SUBLIME_USER_DIR" ]]; then
  for SUBLIME_FILE in sublime/*; do
    SUB_FILE=$(echo $SUBLIME_FILE | cut -d '/' -f2)
    if [[ -e "$SUBLIME_USER_DIR$SUB_FILE" ]]; then
      rm "$SUBLIME_USER_DIR$SUB_FILE"
    fi
    ln -s "$CURR_DIR/$SUBLIME_FILE" "$SUBLIME_USER_DIR$SUB_FILE"
  done
fi

for DOTFILE in homedir/*; do
  DOT=$(echo $DOTFILE | cut -d '/' -f2)
   if [[ -e $HOME/.$DOT ]]; then
    rm $HOME/.$DOT
  fi
  ln -s $CURR_DIR/$DOTFILE $HOME/.$DOT
done

for PREF in preferences/*; do
  PREFFILE=$(echo $PREF | cut -d '/' -f2)
  if [[ -e "$PREF_PATH$PREFFILE" ]]; then
    rm "$PREF_PATH$PREFFILE"
  fi
  ln -s $CURR_DIR/$PREF "$PREF_PATH$PREFFILE"
done

if [[ ! -d $HOME/bin ]]; then
  mkdir $HOME/bin
fi

if [[ ! -d $HOME/.atom ]]; then
  mkdir $HOME/.atom
fi

for ATOMPREF in atom/*; do
  ATOMFILE=$(echo $ATOMPREF | cut -d '/' -f2)
  if [[ -e $HOME/.atom/$ATOMFILE ]]; then
    rm $HOME/.atom/$ATOMFILE
  fi
  ln -s $CURR_DIR/$ATOMPREF $HOME/.atom/$ATOMFILE
done

if [[ ! -f $HOME/bin/initprj ]]; then
  ln -s $HOME/.initprj $HOME/bin/initprj && chmod +x $HOME/bin/initprj
fi

if [[ ! -f $HOME/bin/cnpm ]]; then
  ln -s $HOME/.cnpm $HOME/bin/cnpm && chmod +x $HOME/bin/cnpm
fi

if [[ ! -h $HOME/.vim ]]; then
  mv $HOME/.vim $HOME/.vim-backup
  ln -s $HOME/src/dotfiles/vim $HOME/.vim
fi

if [[ ! -h $HOME/.ssh/config ]]; then
  mv $HOME/.ssh/config $HOME/.ssh/config-backup
  ln -s $HOME/src/dotfiles/ssh_config $HOME/.ssh/config
fi

cd vim && git submodule init && git submodule update
