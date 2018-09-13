export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/flutter/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm


if [ -f $(brew --prefix)/etc/bash_completion ]; then
. $(brew --prefix)/etc/bash_completion
fi


if [ -f ~/bin/sensible.bash ]; then
   source ~/bin/sensible.bash
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

PS1="\u@macbook \w "

export ANDROID_HOME=$HOME/Library/Android/sdk

export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$PATH
export PATH=$PATH:$ANDROID_HOME/platform-tools

export REACT_EDITOR=atom

### Bashhub.com Installation.
### This Should be at the EOF. https://bashhub.com/docs
if [ -f ~/.bashhub/bashhub.sh ]; then
    source ~/.bashhub/bashhub.sh
fi

alias git="hub"
alias l="exa"

export GPG_TTY=$(tty)

# jenv
#export JAVA_HOME=$(/usr/libexec/java_home -v 10.0.1)
export JENV_ROOT=/usr/local/opt/jenv

eval "$(jenv init -)"
