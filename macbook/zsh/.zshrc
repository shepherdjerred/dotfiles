export ZSH="/Users/jerred/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

source $ZSH/oh-my-zsh.sh

# Load plugins
source <(antibody init)
antibody bundle < ~/.antibody

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
