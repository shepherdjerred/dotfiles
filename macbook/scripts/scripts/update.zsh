#!/usr/local/bin/zsh

zsh $ZSH/tools/upgrade.sh
antibody update
brew update; brew upgrade
vim +PlugUpdate +qall

gem update

# pip
pip install --upgrade pip

npm update; npm upgrade
npm install -g npm

asdf update
asdf plugin update --all

yabai --uninstall-sa
yabai --install-sa
killall Dock
