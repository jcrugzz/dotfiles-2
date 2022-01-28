# set up keychain
if command -v keychain >> /dev/null; then
  if [ -f $HOME/.no-rsa ]; then
    echo "Ignoring RSA key"
  else
    if [ -L $HOME/.ssh/id_rsa ]; then
      echo "RSA key already aliased"
    else
      ln -s ${HOME}/.ssh/${HOSTNAME} ${HOME}/.ssh/id_rsa
      ln -s ${HOME}/.ssh/${HOSTNAME}.pub ${HOME}/.ssh/id_rsa.pub
    fi
    eval `keychain --agents ssh --eval ~/.ssh/id_rsa`
  fi

  if [ -f $HOME/.no-ed ]; then
    echo "Ignoring ED25519 key"
  else
    if [ -L $HOME/.ssh/id_ed25519 ]; then
      echo "ED25519 key already aliased"
    else 
      ln -s ${HOME}/.ssh/${HOSTNAME} ${HOME}/.ssh/id_ed25519
      ln -s ${HOME}/.ssh/${HOSTNAME}.pub ${HOME}/.ssh/id_ed25519.pub
    fi
    eval `keychain --agents ssh --eval ~/.ssh/id_ed25519`
  fi

  # see if there are other ssh keys to load
  KEYS=$(fd -t f id_* $HOME/.ssh -E *pub)
  for KEY in $KEYS; do
    echo "Adding ${KEY}"
    eval `keychain --agents ssh --eval $KEY`
  done

  if [ -f $HOME/.no-gpg ]; then
    echo "No GPG agent loaded"
    $GIT config --global --unset commit.gpgsign
    $GIT config --global --unset user.signingKey
  elif [ -f $HOME/.gpg-key ]; then
    GPG_KEY=$(cat $HOME/.gpg-key)
    eval `keychain --agents gpg --eval $GPG_KEY` 
    $GIT config --global commit.gpgsign true
    $GIT config --global user.signingKey $GPG_KEY
  fi
else 
  $GIT config --global --unset commit.gpgsign
  $GIT config --global --unset user.signingKey
fi

