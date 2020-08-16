#!/usr/bin/env zsh

./common/scripts/scripts/apply-common-dotfiles.zsh
stow -v -t ~ -d macbook --ignore=".DS_Store" \
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
