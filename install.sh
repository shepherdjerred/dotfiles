#!/bin/bash

set -eoux pipefail

sudo apt update && sudo apt upgrade -y && sudo apt autoremove
sudo apt install arcanist mosh

mkdir -p ~/code

# install linuxbrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# TODO dir
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/jshepherd/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install chezmoi

# configure
# TODO
# chezmoi init --apply

# symlink dotfiles
ln -s ~/.local/share/chezmoi/ ~/code/dotfiles

# install Brewfile
(cd ~ && brew bundle --file=.Brewfile)

# install languages
mise install --yes

# install fisher
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
chezmoi apply --force && fish -c "fisher update"

# install lunarvim
# note: say no to the python install question; we install this manually
# todo: automate these selections
# manual step: setup copilot with :Copilot auth
LV_BRANCH='release-1.4/neovim-0.9' fish -c "bash -c 'bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)'"

# setup atuin (interactive)
# TODO: make non-interactive
atuin login -u sjerred
atuin import auto
atuin sync

# tmux
# note: must run `prefix + I` to install plugins
# note: must run through fish to use the updated tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# bat
mkdir -p "$(bat --config-dir)/themes"
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
bat cache --build

# delta
mkdir -p ~/.config/delta
git clone https://github.com/catppuccin/delta ~/.config/delta/themes

# add fish to /etc/shells
echo /home/linuxbrew/.linuxbrew/bin/fish | sudo tee -a /etc/shells

# remove bash/zsh files, history, etc
rm -rf ~/.profile ~/.bash_history ~/.bash_logout ~/.bash_profile ~/.bashrc ~/.zsh_history ~/.zshrc
