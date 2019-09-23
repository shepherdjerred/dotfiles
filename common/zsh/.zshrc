export ZSH="/home/jerred/.oh-my-zsh"
ZSH_THEME=powerlevel10k/powerlevel10k
plugins=(
    git
    zsh-histdb
    zsh-syntax-highlighting
    zsh-autosuggestions
    vi-mode
)
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
