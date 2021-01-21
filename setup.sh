#!/usr/bin/env bash
DOTFILE_SRC=$(dirname "${BASH_SOURCE[0]}")
if [ "$DOTFILE_SRC" = "." ]; then
  DOTFILE_SRC=$PWD
fi

echo Script source: $DOTFILE_SRC

if which dpkg >> /dev/null; then
  sudo dpkg -i $DOTFILE_SRC/deb_pkgs/*
fi

mkdir -p $HOME/.config/
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

setup_nvim () {
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
  fi

  if which npm >> /dev/null; then
    npm install coc-omnisharp coc-snippets coc-yaml coc-go coc-tsserver coc-solargraph coc-rust-analyzer coc-json --global-style --ignore-scripts --no-bin-links --no-package-loack --only=prod
  fi
}

setup_dotfiles () {
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
}

setup_bp_bash_profile () {
    sudo cp "$DOTFILE_SRC/enterprise/.bash_profile" /root
}

setup_bp_git () {
    sudo cp "$DOTFILE_SRC/enterprise/.gitconfig" /root
}

# Allow root login
setup_bp_ssh () {
    sudo sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    echo 'AcceptEnv OCTOFACTORY_TOKEN' | sudo tee -a /etc/ssh/sshd_config
    echo 'AcceptEnv GH_PAT' | sudo tee -a /etc/ssh/sshd_config
    sudo mkdir -p /root/.ssh && sudo cp "$DIR/enterprise/config" "$_"
    sudo cat /workspace/.ssh/authorized_keys | sudo tee -a /root/.ssh/authorized_keys
    sudo systemctl restart ssh
}

setup_enterprise () {
    setup_bp_ssh
    setup_bp_git
    setup_bp_bash_profile
}

setup_ssh () {
  mkdir -p ~/.ssh
  if [ -L $HOME/.ssh/config ]; then
    echo "${HOME}/.ssh/config exists!"
  else
    echo "Removing ${HOME}/.ssh/config"
    rm -f $HOME/.ssh/config
    echo "Linking ssh_config to ${HOME}/.ssh/config"
    ln -s ssh_config $HOME/.ssh/config
  fi
}

# Check if host is an enterprise bp instance. If it is run
if [[ $(ghe-dev-hostname 2>/dev/null) == *".bpdev-us-east-1.github.net" ]]; then 
  setup_enterprise
else 
  setup_dotfiles
  setup_nvim
  setup_ssh
fi
