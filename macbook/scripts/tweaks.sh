# Show hidden files
defaults write com.apple.finder AppleShowAllFiles true

# Quit finder menu option
defaults write com.apple.finder QuitMenuItem -bool true && \

# Path bar
defaults write com.apple.finder ShowPathbar -bool true

# Restart finder
killall Finder
