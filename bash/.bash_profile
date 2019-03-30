# flutter
export PATH=/usr/local/flutter/bin:$PATH

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm


# Homebrew
export PATH=/usr/local/bin:$PATH
if [ -f $(brew --prefix)/etc/bash_completion ]; then
. $(brew --prefix)/etc/bash_completion
fi


# Bash sensible
if [ -f ~/bin/sensible.bash ]; then
   source ~/bin/sensible.bash
fi

# iTerm2
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Custom prompt
PS1="\u@macbook \w "

# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$PATH
export PATH=$PATH:$ANDROID_HOME/platform-tools

# React
export REACT_EDITOR=atom

# Chrome alias
alias chrome="open -a \"Google Chrome\""

# hub
alias git="hub"

# exa
alias l="exa"

# GPG
export GPG_TTY=$(tty)

# gitignore.io
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-11.0.2.jdk/Contents/Home

# qt
export PATH="/usr/local/opt/qt/bin:$PATH"

# LaTeX
export PATH="/Library/TeX/texbin:$PATH"

# Travis
# added by travis gem
[ -f /Users/jerred/.travis/travis.sh ] && source /Users/jerred/.travis/travis.sh

# vi keybindings
set -o vi

### Bashhub.com Installation.
### This Should be at the EOF. https://bashhub.com/docs
if [ -f ~/.bashhub/bashhub.sh ]; then
    source ~/.bashhub/bashhub.sh
fi

