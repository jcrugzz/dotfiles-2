set -o vi
PATH=~/bin:/usr/local/bin:~/bin/node-v14.17.4-linux-x64/bin:$PATH
BLUE="\[\033[34m\]"
LIGHT_GRAY="\[\033[0;37m\]"
CYAN="\[\033[0;36m\]"
GREEN="\[\033[0;32m\]"
MAGENTA="\[\033[0;35m\]"
YELLOW="\[\033[0;33m\]"
CYAN="\[\033[0;36m\]"
RED="\[\033[0;31m\]"
OFF="\[\033[0m\]"
VIRTUAL_ENV_DISABLE_PROMPT=true
export BASH_SILENCE_DEPRECATION_WARNING=1
export HOMEBREW_NO_ENV_HINTS=1

if command -v nvim >> /dev/null; then
  EDITOR=nvim
else
  EDITOR=vim
fi

umask 002
HISTTIMEFORMAT="%d/%m/%y %T "

if [ -f $HOME/.cargo/env ]; then
  . "$HOME/.cargo/env"
else 
  echo "NO FUCKING CARGO"
fi

#aliases
alias gs="git status"
alias gd="git diff"
alias gl="git lg"
alias rmnm="rm -rf node_modules/ && npm install"
alias clip="nc -U ~/.clipper.sock"

if command -v kubectl >> /dev/null; then
  source <(kubectl completion bash)
fi

if command -v exa >> /dev/null; then
  alias ls="exa"
  alias dir="exa -lmFh --git"
else
  if [ "$(uname)" = "Darwin" ]; then
    alias dir="ls -lGFht"
  else
    alias dir="ls -ltF --color=auto"
  fi
fi

if command -v btm >> /dev/null; then
  alias top="btm"
  alias htop="btm"
fi

if command -v fd >> /dev/null; then
  alias find="fd"
fi

if command -v fdfind >> /dev/null; then
  alias find="fdfind"
fi

if command -v bat >> /dev/null; then
  alias cat="bat"
fi

if command -v batcat >> /dev/null; then
  alias cat="batcat"
fi

if command -v delta >> /dev/null; then
  git config --global core.pager "delta --theme='Dracula'"
  git config --global interactive.diffFilter "delta --color-only"
else 
  git config --global --unset core.pager
  git config --global --unset interactive.diffFilter
fi

# install nice gitlog if it's not there...
if [ -z "$(git config --global alias.lg)" ]; then
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
fi

if [ -z "$(git config --global alias.co)" ]; then
    git config --global alias.co "checkout"
fi

function gp () {
    git push -u origin $(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p') $@
}

GIT=$(which git)

if command -v brew >> /dev/null; then
  [ -f $(brew --prefix)/etc/bash_completion.d/git-completion.bash ] && . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
fi

function delete-branches() {
  XARGS_BIN=xargs
  if command -v gxargs >> /dev/null; then
    XARGS_BIN=gxargs
  fi
  git branch |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --multi --preview="git log {}" |
    gxargs --no-run-if-empty git branch --delete --force
}

if command -v keychain >> /dev/null; then
  if [ -f $HOME/.no-rsa ]; then
    echo "Ignoring RSA key"
  else
    if [ -L $HOME/.ssh/id_rsa ]; then
      echo "RSA key already aliased"
    else
      ln -s ${HOME}/.ssh/${HOSTNAME} ${HOME}/.ssh/id_rsa
      ln -s ${HOME}/.ssh/${HOSTNAME}.pub ${HOME}/.ssh/id_rsa.pub
    fi
    eval `keychain --agents ssh --eval ~/.ssh/id_rsa`
  fi

  if [ -f $HOME/.no-ed ]; then
    echo "Ignoring ED25519 key"
  else
    if [ -L $HOME/.ssh/id_ed25519 ]; then
      echo "ED25519 key already aliased"
    else 
      ln -s ${HOME}/.ssh/${HOSTNAME} ${HOME}/.ssh/id_ed25519
      ln -s ${HOME}/.ssh/${HOSTNAME}.pub ${HOME}/.ssh/id_ed25519.pub
    fi
    eval `keychain --agents ssh --eval ~/.ssh/id_ed25519`
  fi

  # see if there are other ssh keys to load
  KEYS=$(fd -t f id_* $HOME/.ssh -E *pub)
  for KEY in $KEYS; do
    echo "Adding ${KEY}"
    eval `keychain --agents ssh --eval $KEY`
  done

  if [ -f $HOME/.no-gpg ]; then
    echo "No GPG agent loaded"
    $GIT config --global --unset commit.gpgsign
    $GIT config --global --unset user.signingKey
  elif [ -f $HOME/.gpg-key ]; then
    GPG_KEY=$(cat $HOME/.gpg-key)
    eval `keychain --agents gpg --eval $GPG_KEY` 
    $GIT config --global commit.gpgsign true
    $GIT config --global user.signingKey $GPG_KEY
  fi
else 
  $GIT config --global --unset commit.gpgsign
  $GIT config --global --unset user.signingKey
fi

if [ -f $HOME/.git-email ]; then
  GIT_EMAIL=$(cat $HOME/.git-email)
  $GIT config --global user.email $GIT_EMAIL
fi

[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh
[ -f $HOME/.asdf/asdf/completions/asdf.bash ] && . $HOME/.asdf/completions/asdf.bash
if command -v direnv >> /dev/null; then
  eval "$(direnv hook bash)"
fi

if command -v zoxide >> /dev/null; then
  eval "$(zoxide init bash)"
fi

export GPG_TTY=$(tty)
export PATH PS1 EDITOR TERMINAL
if command -v starship >> /dev/null; then
  eval "$(starship init bash)"
fi

git config --global core.excludesFile "${HOME}/.gitignore"

. $HOME/.config/bash/current-hostname
