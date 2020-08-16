#!/usr/bin/env zsh

./common/scripts/scripts/apply-dotfiles.sh
stow -v -t ~ -d server \
  git \
  scripts \
  tmux \
  zsh
