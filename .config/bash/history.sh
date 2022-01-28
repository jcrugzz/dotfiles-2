# control history
shopt -s histappend
HISTFILESIZE=
HISTSIZE=
HISTCONTROL=ignoreboth
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
