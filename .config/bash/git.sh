# configure git diff command
GIT=$(which git)
$GIT config --global core.excludesFile "${HOME}/.gitignore"
if command -v delta >> /dev/null; then
  $GIT config --global core.pager "delta --theme='Dracula'"
  $GIT config --global interactive.diffFilter "delta --color-only"
else 
  $GIT config --global --unset core.pager
  $GIT config --global --unset interactive.diffFilter
fi

# install nice gitlog if it's not there...
if [ -z "$($GIT config --global alias.lg)" ]; then
    $GIT config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
fi

# add shorthand for checkout
if [ -z "$($GIT config --global alias.co)" ]; then
    $GIT config --global alias.co "checkout"
fi

# add function to push current branch to origin
function gp () {
    $GIT push -u origin $(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p') $@
}

# use fzf to delete branches nicely
function delete-branches() {
  XARGS_BIN=xargs
  if command -v gxargs > /dev/null; then
    XARGS_BIN=gxargs
  fi
  git branch |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --multi --preview="git log {}" |
    $XARGS_BIN --no-run-if-empty git branch --delete --force
}

if [ -f $HOME/.git-email ]; then
  GIT_EMAIL=$(cat $HOME/.git-email)
  $GIT config --global user.email $GIT_EMAIL
fi

