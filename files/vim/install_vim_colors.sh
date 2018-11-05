#!/usr/bin/env bash
# Move colors to vim config directory
mkdir -p ~/.vim/colors
cp -R colors ~/.vim

# Move plugins to vim config directory
mkdir -p ~/.vim/plugins
cp -R plugins ~/.vim
cat .vimrc > ~/.vimrc
