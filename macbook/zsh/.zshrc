export ZSH="/Users/jerred/.oh-my-zsh"

source $ZSH/oh-my-zsh.sh

# Load plugins
source <(antibody init)
antibody bundle < ~/.antibody

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

