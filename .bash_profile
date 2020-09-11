PATH=~/bin:/usr/local/bin:$PATH
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
if command -v nvim >> /dev/null; then
  EDITOR=nvim
else
  EDITOR=vim
fi
# PS1="$YELLOW\w$OFF\$(git_prompt)\$(server_info)\n[$CYAN\D{%H:%M:%S}$OFF] \$ "
TERMINAL=gnome-terminal
TERM=xterm-256color
umask 002

#aliases
alias gs="git status"
alias gd="git diff"
alias gl="git lg"
alias rmnm="rm -rf node_modules/ && npm install"

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

if command -v bat >> /dev/null; then
  alias cat="bat"
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

function server_info {
  SERV_INFO=""
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]
  then SERV_INFO="$(hostname)@$(whoami)"
  else SERV_INFO="$(hostname)"
  fi
  echo -ne " on $SERV_INFO"
}

GIT=$(which git)

function git_prompt (){
    if ! $GIT rev-parse --git-dir > /dev/null 2>&1; then
        return 0
    fi

    UNCOMMITED=$($GIT diff-index --quiet HEAD --)
    UNADDED=$($GIT ls-files --other --exclude-standard --directory --no-empty-directory)
    BRANCH=$($GIT branch 2>/dev/null| sed -n '/^\*/s/^\* //p')
    GIT_PROMPT=$BRANCH
    PROMPT_COLOR="\033[0;32m"

    if [ -n "$UNCOMMITTED" ]
    then
        PROMPT_COLOR="\033[0;36m"
    fi

    if [ -n "$UNADDED" ]
    then
        PROMPT_COLOR="\033[0;31m"
    fi

    echo -e ":$PROMPT_COLOR$GIT_PROMPT\033[0m"
}

if command -v brew >> /dev/null; then
  [ -f $(brew --prefix)/etc/bash_completion.d/git-completion.bash ] && . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
fi

if command -v keychain >> /dev/null; then
  eval `keychain --agents ssh --eval ~/.ssh/id_ed25519`
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

[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh
[ -f $HOME/.asdf/asdf/completions/asdf.bash ] && . $HOME/.asdf/completions/asdf.bash
if command -v direnv >> /dev/null; then
  eval "$(direnv hook bash)"
fi

export GPG_TTY=$(tty)
export PATH="$HOME/.cargo/bin:$PATH"
export PATH PS1 EDITOR TERMINAL
if command -v starship >> /dev/null; then
  eval "$(starship init bash)"
fi
