#!/bin/bash

export NONINTERACTIVE=1

apt update
apt upgrade -y
apt install -y git curl

# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> /root/.bashrc
echo 'eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"' >> /root/.bashrc
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

brew install chezmoi
chezmoi init --apply https://github.com/shepherdjerred/dotfiles

brew bundle install

# fish
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
echo $HOMEBREW_PREFIX/bin/fish > /etc/shells
# chsh -s $HOMEBREW_PREFIX/bin/fish

fisher install
