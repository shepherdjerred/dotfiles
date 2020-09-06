#!/usr/bin/env zsh

./common/scripts/scripts/apply-common-dotfiles.zsh
stow -v -t ~ -d server --ignore=".DS_Store" \
  git \
  scripts \
  tmux \
  zsh
