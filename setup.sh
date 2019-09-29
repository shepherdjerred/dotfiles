#!/bin/bash

sudo apt install curl zsh tmux git stow exa

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/larkery/zsh-histdb $HOME/.oh-my-zsh/custom/plugins/zsh-histdb
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git


# powerlevel10k
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

mkdir git
cd git
git clone https://github.com/ShepherdJerred/dotfiles
cd dotfiles
stow vim tmux git -t ~

# vim plugged
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install vim plugins
vim +PlugInstall +qall

# TODO install gpg keys
# TODO copy ssh keys
# TODO git key encryption
# TODO hide gpg prompt
# TODO zsh completions
# TODO more zsh plugins
# TODO 