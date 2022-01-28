# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/tkennedy1/src/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/src/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/src/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "$HOME/src/fzf/shell/key-bindings.bash"
