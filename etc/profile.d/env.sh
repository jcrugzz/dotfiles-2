if [ -d "$HOME/.cargo/bin" ]; then
	PATH="$HOME/.cargo/bin":$PATH
fi

if [ -d "$HOME/bin" ]; then
	PATH="$HOME/bin":$PATH
fi
