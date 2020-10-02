#!/bin/bash

# Session utils
export DOTFILES='/workspace/.dotfiles'

alias reload='source ~/.bash_profile'
alias ls='ls -lhpA --group-directories-first'
alias dotfiles.update='cd "$DOTFILES" && git pull origin master && cp "$DOTFILES/enterprise/bash/.bash_profile" ~/ && reload'

# Docker utils
alias docker.octo.login='docker login octofactory.githubapp.com -u toddself -p "$OCTOFACTORY_TOKEN"'
alias docker.gpr.login='docker login https://docker.pkg.github.com -u toddself -p "$GH_PAT"'
alias docker.ghcr.login='docker login containers.pkg.github.com -u toddself -p "$GH_PAT"'
alias docker.login='docker.octo.login && docker.gpr.login && docker.ghcr.login'

# Enterprise utils
export PATH="$PATH:/workspace/enterprise2"
export OVERLAY_VM_FILES='yes'
export ENABLE_HYDRO=1
export ENABLE_ISOLATION=1
export ENABLE_PACKAGES=1

alias gh.build='DEBUG_BUILD=1 chroot-build.sh'
alias gh.configure='chroot-configure.sh && gh.ssh setup_ssh'
alias gh.start='chroot-start.sh'
alias gh.stop='chroot-stop.sh'
alias gh.reset='chroot-reset.sh'
alias gh.info='chroot-info.sh'
alias gh.gw='chroot-add-gw.sh'
alias gh.configs='gh.ssh ghe_config_wrapper'
alias gh.secrets='gh.ssh ghe_config_wrapper -s'
alias gh.proxy='sudo update-reverse-proxy'
alias gh.init='gh.cr.update && docker.login && gh.build && gh.start && gh.gw && gh.configure && gh.proxy'
alias gh.rebuild='gh.stop && gh.reset && gh.build && gh.start && gh.configure'
alias gh.destroy='sudo shutdown 0'
gh.ssh () {

    BASH_PROFILE="$DOTFILES/enterprise/bash/.appliance_bash_profile"
    [[ -f $BASH_PROFILE ]] && chroot-scp.sh --to "$BASH_PROFILE" /home/admin/.bash_profile > /dev/null

    if [[ $# -eq 0 ]]; then
        chroot-ssh.sh
    else
        chroot-ssh.sh ". .bash_profile && $*"
    fi
}

gh.patch () {
    sudo sed -i 's/export GITHUB_SHA.*/export GITHUB_SHA=${GITHUB_SHA:-8f21f606f6ade467daa260e3b77252fc6520c214}/' /workspace/enterprise2/configuration.sh
    sudo sed -i 's/export HYDRO_SCHEMAS_SHA.*/export HYDRO_SCHEMAS_SHA=${HYDRO_SCHEMAS_SHA:-7676cd9248c89105157a344d4a78e54e9eaf93aa}/' /workspace/enterprise2/configuration.sh
    # sudo sed -i 's/registry-metadata.*/registry-metadata=octofactory.githubapp.com\/moda-artifacts-docker\/registry-metadata:fb9ed6b420c0fe85e25eb1d5189e92a32eb3fe8f@sha256:38c11e42fdf9de389ed452dec93ea6cd61ae97470b6e128fc3168fab84b52822/' /workspace/enterprise2/docker-image-list-ghe
    sudo sed -i 's/container-registry.*/container-registry=octofactory.githubapp.com\/moda-artifacts-docker\/container-registry:2dfe222358e7ce4c4bf3f52dc8d6ac94c061f8d4@sha256:1c6af44d41f16e2dd08da3936beefbb9544cae047b42fbbf41fbe945b02f2247/' /workspace/enterprise2/docker-image-list-ghe
    sudo sed -i "s/  initialize_if_unset 'secrets.packages-v2.blob-store' 's3'.*/  initialize_if_unset 'secrets.packages-v2.blob-store' 'filesystem'/" /workspace/enterprise2/vm_files/usr/local/share/enterprise/ghe-secrets-init
}
