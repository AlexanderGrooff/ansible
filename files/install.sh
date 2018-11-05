#!/usr/bin/env bash

if [ "$1" == "" ]; then
    echo "Found no install parameter! Aborting"
    exit 1
fi

if [ -z "$HOME" ]; then
    echo "\$HOME is empty, aborting"
    exit 1
fi

if [ -z "$HOST" ]; then
    HOST=$(hostname)
fi

if [ ! -d $HOME/.local ]; then
    mkdir -p $HOME/.local
    chmod 700 $HOME/.local
fi
if [ ! -d $HOME/.local/bin ]; then
    mkdir -p $HOME/.local/bin
fi
bindir=$HOME/.local/bin

root=$(dirname "$(readlink -f "$0")")
scripts=$root/scripts


install() {
    name="$1"
    func="install_$(echo $1 | tr -s '-' '_')"
    cmd=${2:-$1}
    if command -v $cmd >/dev/null 2>&1; then
        printf "Setting up %s ... " "$name"
        $func
        echo "done"
    fi
}


install_git() {
    ln -sf $scripts/git-all-my-logs.sh $bindir/git-all-my-logs
}


install_iterm2() {
    echo "Installing ohmyzsh"
    ./iterm2/install_oh_my_zsh.sh
    echo "Setting ZSH theme in ~/.zshrc to 'agnoster'"
    perl -pi -e 's/ZSH_THEME=\"\w+\"/ZSH_THEME="agnoster"/g' ~/.zshrc
    echo "Installing zsh highlighting"
    brew install zsh-syntax-highlighting
}

install $1
