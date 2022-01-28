# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/tkennedy1/src/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/Users/tkennedy1/src/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/tkennedy1/src/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/Users/tkennedy1/src/fzf/shell/key-bindings.bash"
