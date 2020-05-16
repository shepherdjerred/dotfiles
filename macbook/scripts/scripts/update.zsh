#!/usr/local/bin/zsh
zsh $ZSH/tools/upgrade.sh
antibody update
brew update; brew upgrade
vim +PlugUpdate +qall
gem update
# pip
pip install --upgrade pip
npm update; npm upgrade

asdf update

_ yabai --uninstall-sa
_ yabai --install-sa
