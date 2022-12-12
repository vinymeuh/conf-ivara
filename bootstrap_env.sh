export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"

[ ! -e $HOME/.zshrc ] && ln -s "$HOME/conf-ivara/dotfiles/zshrc" "$HOME/.zshrc"
