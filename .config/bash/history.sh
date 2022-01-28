# control history
shopt -s histappend
HISTFILESIZE=-1
HISTSIZE=-1
HISTCONTROL=ignoreboth
HISTIGNORE=z:ls:bg:fd:history:fzf:cd
PROMPT_COMMAND="history -a; history -n;$PROMPT_COMMAND"
