#!/usr/bin/env zsh

./common/scripts/scripts/apply-dotfiles.sh
stow -v -t ~ -d macbook \
  antibody \
  git \
  gpg \
  python \
  ruby \
  scripts \
  skhd \
  ssh \
  tmux \
  tmuxinator \
  yabai \
  zsh
