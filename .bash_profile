# use vim keybindings
set -o vi

# export some variables
PATH=~/bin:/usr/local/bin:~/go/bin:$PATH
VIRTUAL_ENV_DISABLE_PROMPT=true
export BASH_SILENCE_DEPRECATION_WARNING=1
export HOMEBREW_NO_ENV_HINTS=1
export GPG_TTY=$(tty)
export PATH PS1 EDITOR TERMINAL
export GOPATH=$HOME/go
if [ -z $XDG_CONFIG_HOME ]; then
  export XDF_CONFIG_HOME=$HOME/.config
fi

# do we have an nvim?
if command -v nvim >> /dev/null; then
  EDITOR=nvim
else
  EDITOR=vim
fi

umask 002

# load rust tools
if [ -f $HOME/.cargo/env ]; then
  . "$HOME/.cargo/env"
else 
  echo "cargo missing"
fi

[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh
[ -f $HOME/.asdf/asdf/completions/asdf.bash ] && . $HOME/.asdf/completions/asdf.bash

if command -v brew >> /dev/null; then
  [ -f $(brew --prefix)/etc/bash_completion.d/git-completion.bash ] && . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
  [ -f $(brew --prefix)/etc/bash_completion.d/docker ] && . $(brew --prefix)/etc/bash_completion.d/docker
  [ -f $(brew --prefix)/etc/bash_completion.d/gh ] && . $(brew --prefix)/etc/bash_completion.d/gh
fi

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash

for CONFIG_FILE in $HOME/.config/bash/*.sh; do
  . $CONFIG_FILE
done

[ -f $HOME/.config/bash/current-hostname ] && . $HOME/.config/bash/current-hostname
