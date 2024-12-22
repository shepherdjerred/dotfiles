#!/bin/bash

export NONINTERACTIVE=1

apt update
apt upgrade -y
apt install -y curl build-essential git

# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> /root/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /root/.bashrc

brew install chezmoi
chezmoi init --source=~/dotfiles --apply

# brew bundle install
brew install neovim mise fish git curl starship carapace atuin eza bat ripgrep zellij btop difftastic git-delta

# fish
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
echo /home/linuxbrew/.linuxbrew/bin/brew/bin/fish > /etc/shells
# chsh -s /home/linuxbrew/.linuxbrew/bin/brew/bin/fish

# fisher overwrite the plugin file
chezmoi apply

fish -c "fisher update"

# todo: install mise if needed
mise install

# /root/.local/bin/lvim
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)
