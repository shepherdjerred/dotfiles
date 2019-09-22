#!/usr/local/bin/bash
ls /Applications > applications.txt
brew list > brew.txt
brew cask list > brew-cask.txt
brew bundle dump
