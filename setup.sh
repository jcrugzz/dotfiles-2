#!/usr/bin/env bash
DOTFILE_SRC=$(dirname "${BASH_SOURCE[0]}")
if [ "$DOTFILE_SRC" = "." ]; then
  DOTFILE_SRC=$PWD
fi

OS_NAME=$(uname -s | tr A-Z a-z)
ARCH=$(uname -m)
if command -v lsb_release >> /dev/null; then
  DISTRO=$(lsb_release -is | tr A-Z a-z)
else
  echo "Missing lsb_release tool"
  if [ "$OS_NAME" = "linux" ]; then
    exit 1
  fi
fi

if command -v hostnamectl >> /dev/null; then
  HOSTNAME=$(hostnamectl hostname)
else
  HOSTNAME=$(hostname)
fi

NODE_VERSION="16.13.0"
PYTHON_VERSION="3.10.0"
ASDF_VERSION="0.8.1"
FZF_VERSION=0.27.3
NEOVIM_VERSION=0.5.0

echo "Script source: ${DOTFILE_SRC}, OS: ${OS_NAME}, ARCH: ${ARCH}, DISTRO: ${DISTRO}"

mkdir -p $HOME/bin
mkdir -p $HOME/.config/

CARGO_PACKAGES="git-delta zoxide fd-find bottom bat exa starship"

install_os_packages () {
  echo "INSTALLING OS PACKAGES"
  if [ "$OS_NAME" = "linux" ]; then
    if [ "$DISTRO" = "arch" ]; then
      echo "-> Installing packages from arch"
      sudo pacman -Sy --needed $(comm -12 <(pacman -Slq|sort) <(sort pkglist.txt))
      echo "-> Installing pacaur"
      mkdir $HOME/.pacaur
      pushd $HOME/.pacaur
      git clone https://aur.archlinux.org/auracle-git.git
      pushd $HOME/.pacaur/auracle-git
      makepkg -sic
      popd
      git clone https://aur.archlinux.org/pacaur.git
      pushd $HOME/.pacaur/pacaur
      makepkg -sic
      popd
      popd
      echo "-> Installing packages from AUR"
      pacaur -S --noedit --noconfirm --needed $(cat aur-pkglist.txt)
    elif [ "$DISTRO" = "ubuntu" ] || [ "${DISTRO}" = "debian" ]; then
      # needed for appimages to work
      sudo apt install -y base-devel git libfuse2 libssl-dev xz-utils
    fi
    echo "-> Installing neovim appimage"
    # Install neovim
    mkdir -p $HOME/bin
    curl -L -o $HOME/bin/nvim https://github.com/neovim/neovim/releases/download/$NEOVIM_VERSION/nvim.appimage
    chmod a+x $HOME/bin/nvim
  else
    "-> Installing xcode command line tools"
    xcode-select --install
    "-> Installing homebew"
    /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    "-> Installing from homebrew"
    brew bundle
    defaults write -g ApplePressAndHoldEnabled -bool false
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
    defaults write NSGlobalDomain KeyRepeat -int 0z
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"
    defaults write com.apple.screencapture type -string "png"
    defaults write com.apple.screencapture disable-shadow -bool true
    defaults write com.apple.finder DisableAllAnimations -bool true
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    chflags nohidden ~/Library
  fi
  touch $HOME/.no-os-packages
  echo "INSTALLED OS PACKAGES"
}

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
    source $HOME/.cargo/env
  fi

  if [ -f $DOTFILE_SRC/$OS_NAME-$ARCH-bin.tar.xz ]; then
    echo "Copying pre-built binaries for ${OS_NAME} ${ARCH}"
    pushd $HOME/bin
    tar xJf $DOTFILE_SRC/$OS_NAME-$ARCH-bin.tar.xz
    popd
  else
    echo "No pre-built binaries, building from scratch (this might take a while...)"
    for PKG in $CARGO_PACKAGES; do
      cargo install $PKG
    done
  fi
  echo "CONFIGURED RUST"
}

setup_dotdirs () {
  DOT_DIRS=$(find $DOTFILE_SRC -type d -name ".*" | grep -v "git")
  echo "SETTING UP DOTDIRS"
  for DOT_DIR in $DOT_DIRS; do
    for CONFIG_FILE in $(find $DOT_DIR -type f); do
      DEST_FILE=$HOME/$(echo $CONFIG_FILE | sed "s|${DOTFILE_SRC}/||")
      DEST_DIR=$(dirname $DEST_FILE)
      SRC_DIR=$(dirname $CONFIG_FILE)
      mkdir -p $DEST_DIR

      if [ "$CONFIG_FILE" = "$SRC_DIR/$HOSTNAME" ]; then
        HOST_SPECIFIC_CONFIG=$DEST_DIR/current-hostname
        if [ -L $HOST_SPECIFIC_CONFIG ]; then
          echo "${HOST_SPECIFIC_CONFIG} already exists!"
        else
          echo "Removing ${HOST_SPECIFIC_CONFIG}"
          rm -f $HOST_SPECIFIC_CONFIG
          echo "Linking ${CONFIG_FILE} to ${HOST_SPECIFIC_CONFIG}"
          ln -s $CONFIG_FILE $HOST_SPECIFIC_CONFIG
        fi
      else
        if [ -L $DEST_FILE ]; then
          echo "${DEST_FILE} already exists!"
        else
          echo "Removing ${DEST_FILE}"
          rm -f $DEST_FILE
          echo "Linking ${CONFIG_FILE} to ${DEST_FILE}"
          ln -s $CONFIG_FILE $DEST_FILE
        fi
      fi
    done
  done
  echo "DONE SETTING UP DOTDIRS"
}

setup_asdf () {
  if [ ! -d $HOME/.asdf ]; then
    echo "CONFIGURING ASDF"
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch "v${ASDF_VERSION}"
    . $HOME/.asdf/asdf.sh
    asdf plugin add python
    asdf install python $PYTHON_VERSION
    asdf global python $PYTHON_VERSION
    asdf plugin add nodejs
    asdf install nodejs $NODE_VERSION
    asdf global nodejs $NODE_VERSION
    echo "DONE CONFIGURING ASDF"
  else
    echo "ASDF ALREADY CONFIGURED"
    . $HOME/.asdf/asdf.sh
  fi
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

setup_nvim () {
  echo "CONFIGURING NVIM"
  python3 -m pip install --user --upgrade pynvim
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

setup_ssh () {
  echo "CONFIGURING SSH"
  if [ ! -f $HOME/.ssh/authorized_keys ]; then
    curl -o $HOME/.ssh/authorized_keys https://github.com/toddself.keys
  fi 
  chmod -R 600 $HOME/.ssh/*
  echo "SSH CONFIGURED"
}

# we need python installed first...
if [ ! -f $HOME/.no-os-packages ]; then
  install_os_packages
else
  echo "NOT INSTALLING OS PACKAGES"
fi

setup_asdf
setup_dotfiles
setup_dotdirs
setup_nvim
setup_ssh
setup_rust
