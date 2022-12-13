#!/usr/bin/env zsh
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"

[ ! -e $HOME/.gitconfig ] && ln -s $HOME/conf-ivara/dotfiles/gitconfig $HOME/.gitconfig
[ ! -e $HOME/.zshrc ] && ln -s $HOME/conf-ivara/dotfiles/zshrc $HOME/.zshrc
source $HOME/.zshrc
