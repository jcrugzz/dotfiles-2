#!/usr/bin/env bash
DOTFILE_SRC=$(dirname "${BASH_SOURCE[0]}")
if [ "$DOTFILE_SRC" = "." ]; then
  DOTFILE_SRC=$PWD
fi

OS_NAME=$(uname | tr A-Z a-z)
ARCH=$(uname -m)

echo Script source: $DOTFILE_SRC

mkdir -p $HOME/bin
mkdir -p $HOME/.config/

CARGO_PACKAGES="git-delta zoxide fd-find bottom bat exa starship"

if command -v apt >> /dev/null; then
  sudo apt install -y libfuse2 libssl-dev
fi

setup_rust() {
  echo "CONFIGURING RUST"
  if command -v rustup >> /dev/null; then
    echo "rustup installed, validating toolchain"
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o install-rust.sh
  fi

  if command -v cargo >> /dev/null; then
    echo "cargo installed"
  else
    echo "installing rust toolchain"
    sh ./install-rust.sh --default-toolchain stable -y
  fi

  if [ "$OS_NAME" = "linux" ] && [ "$ARCH" = "x86_64" ]; then
    echo "Using x86_64 linux, copying pre-build binaries"
    ln -fs $DOTFILE_SRC/bin-x86_64/* $HOME/bin/.
  else
    for PKG in $CARGO_PACKAGES; do
      cargo install $PKG
    done
  fi
	if which starship >> /dev/null; then
	  if [ -L $HOME/.config/starship.toml ]; then
	    echo "${HOME}/.config/starship.toml exists!"
	  else
	    echo "Removing ${HOME}/.config/starship.toml"
	    rm -f $HOME/.config/starship.toml
	    echo "Linking ${DOTFILE_SRC}/.config/starship.toml to ${HOME}/.config/starship.toml"
	    ln -s $DOTFILE_SRC/.config/starship.toml $HOME/.config/starship.toml
	  fi
	fi
  echo "CONFIGURED RUST"
}

setup_nvim () {
  echo "CONFIGURING NVIM"
  if ! command -v node >> /dev/null; then
    # Install node
    echo "Installing node"
    curl -sL https://nodejs.org/dist/v14.17.4/node-v14.17.4-linux-x64.tar.xz | unxz | tar xC $HOME/bin
    ln -fs $HOME/bin/node-v14.17.4-linux-x64/bin/* $HOME/bin/.
    $HOME/bin/npm install -g npm
  fi

  if ! command -v fzf >> /dev/null; then
    # Install fzf
    echo "Installing fzf"
    curl -sL https://github.com/junegunn/fzf/releases/download/0.27.3/fzf-0.27.3-linux_amd64.tar.gz | tar xzC $HOME/bin
  fi
  
  if [ $OS_NAME = "linux" ]; then
    if ! command -v nvim >> /dev/null; then
      echo "Installing neovim appimage"
      # Install neovim
      mkdir -p $HOME/bin
      curl -L -o $HOME/bin/nvim https://github.com/neovim/neovim/releases/download/v0.5.0/nvim.appimage
      chmod a+x $HOME/bin/nvim
    fi
  fi

  if command -v python3 >> /dev/null; then
    python3 -m pip install --user --upgrade pynvim
  else
    echo "Could not install the pynvim provider; missing python3 command"
  fi

  mkdir -p $HOME/.config/nvim/snippets
  if [ -L $HOME/.config/nvim/init.vim ]; then
    echo "${HOME}/.config/nvim/init.vim exists!"
  else
    echo "Removing ${HOME}/.config/nvim/init.vim"
    rm -f $HOME/.config/nvim/init.vim
    echo "Linking ${DOTFILE_SRC}/.config/nvim/init.vim to ${HOME}/.config/nvim/init.vim"
    ln -s $DOTFILE_SRC/.config/nvim/init.vim $HOME/.config/nvim/init.vim
  fi

  if [ -L $HOME/.config/nvim/coc-settings.json ]; then
    echo "${HOME}/.config/nvim/coc-settings.json exists!"
  else
    echo "Removing ${HOME}/.config/nvim/coc-settings.json"
    rm -f $HOME/.config/nvim/coc-settings.json
    echo "Linking ${DOTFILE_SRC}/.config/nvim/coc-settings.json to ${HOME}/.config/nvim/coc-settings.json"
    ln -s $DOTFILE_SRC/.config/nvim/coc-settings.json $HOME/.config/nvim/coc-settings.json
  fi

  mkdir -p ~/.config/coc/extensions
  cd ~/.config/coc/extensions
  if [ ! -f package.json ]; then
    echo '{"dependencies":{}}' > package.json
    if which npm >> /dev/null; then
      $HOME/bin/npm install coc-deno coc-snippets coc-yaml coc-go coc-tsserver coc-solargraph coc-rust-analyzer coc-json --global-style --ignore-scripts --no-bin-links --no-package-loack --only=prod
    fi

  fi

  nvim --headless +'PlugInstall --sync' +qa
  echo "NVIM CONFIGURED"
}

setup_dotfiles () {
  echo "CONFIGURING DOTFILES"
  for DOTFILE in $(find $DOTFILE_SRC -type f -name ".*"); do
    FN=$(basename $DOTFILE) 
    if [ -L $HOME/$FN ]; then
      echo "${HOME}/${FN} exists!"
    else
      echo "Removing ${HOME}/${FN}"
      rm -f $HOME/$FN
      echo "Linking ${DOTFILE} to ${HOME}/${FN}"
      ln -s $DOTFILE $HOME/$FN
    fi
  done
  echo "DOTFILES CONFIGURED"
}

setup_ssh () {
  echo "CONFIGURING SSH"
  mkdir -p ~/.ssh
  if [ -L $HOME/.ssh/config ]; then
    echo "${HOME}/.ssh/config exists!"
  else
    echo "Removing ${HOME}/.ssh/config"
    rm -f $HOME/.ssh/config
    echo "Linking ssh_config to ${HOME}/.ssh/config"
    ln -s ssh_config $HOME/.ssh/config
  fi
  chmod -R 600 $HOME/.ssh/*
  echo "SSH CONFIGURED"
}

setup_asdf () {
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
  . $HOME/.asdf/asdf.sh
  if command -v python3 >> /dev/null; then
	  PYVER=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f2)
	  if [ $((PYVER)) -lt $((9)) ]; then
	    asdf plugin add python
	    asdf install python 3.9.7
	    asdf global python 3.9.7
	  fi
  else
	    asdf plugin add python
	    asdf install python 3.9.7
	    asdf global python 3.9.7
	  
  fi
}

setup_linux () {
  for PROG in waybar sway; do
    mkdir -p $HOME/.config/$PROG
    if [ -L $HOME/.config/$PROG/config ]; then
      echo "${HOME}/.config/${PROG}/config exists!"
    else
      echo "Removing ${HOME}/.config/${PROG}/config"
      rm -rf $HOME/.config/$PROG/config
      echo "Linking ${PROG}/config to ${HOME}/.config/${PROG}/config"
      ln -s $DOTFILE_SRC/.config/${PROG}/config $HOME/.config/${PROG}/config
    fi
  done
}

setup_alacritty () {
  if [ -L $HOME/.config/alacritty/alacritty.yml ]; then
    echo "${HOME}/.config/alacritty/alacritty.yml exists!"
  else
    echo "Removing ${HOME}/.config/alacritty/alacritty.yml!"
    rm -rf $HOME/.config/alacritty/alacritty.yml
    echo "Linking ${PROG}/config/alacritty/alacritty-${OS_NAME}.yml to ${HOME}/.config/alacritty/alacritty.yml"
    ln -s $DOTFILE_SRC/.config/alacritty/alacritty-$OS_NAME.yml $HOME/.config/alacritty/alacritty.yml
  fi
}

setup_macos () {
  # todo
  echo "TODO"
}

# we need python installed first...
setup_asdf
setup_dotfiles
setup_nvim
setup_ssh
setup_rust

if [ "$OS_NAME" = "linux" ]; then
  setup_linux
elif [ "$OS_NAME" = "dawin" ]; then
  setup_macos
fi

setup_alacritty
