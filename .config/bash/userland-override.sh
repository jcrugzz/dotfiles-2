# replace userland tools
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

if command -v direnv >> /dev/null; then
  eval "$(direnv hook bash)"
fi

if command -v zoxide >> /dev/null; then
  eval "$(zoxide init bash)"
fi

if command -v starship >> /dev/null; then
  eval "$(starship init bash)"
fi

