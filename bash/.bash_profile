# Homebrew
export PATH=/usr/local/bin:$PATH

# Bash compleition
if [ -f $(brew --prefix)/etc/bash_completion ]; then
. $(brew --prefix)/etc/bash_completion
fi

# Bash sensible
if [ -f ~/bash/bash-sensible/sensible.bash ]; then
   source ~/bash/bash-sensible/sensible.bash
fi

# Bash git prompt
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  GIT_PROMPT_ONLY_IN_REPO=1
  GIT_PROMPT_THEME=Single_line
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

# source ~/.bash-powerline.sh

# iTerm2i integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Custom prompt
PS1="\u@macbook \w "

# Chrome alias
alias chrome="open -a \"Google Chrome\""

# hub
alias git="hub"

# exa
alias l="exa"

# GPG
export GPG_TTY=$(tty)

# LaTeX
export PATH="/Library/TeX/texbin:$PATH"

# vi keybindings
set -o vi

