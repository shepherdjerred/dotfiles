#!/usr/bin/env zsh

stow -v -t ~ -d common --ignore=".DS_Store" \
  asdf \
  aws \
  scripts \
  vim \
  zsh
