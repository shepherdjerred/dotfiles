fish_add_path /opt/homebrew/bin
fish_add_path /Users/jerred/.local/bin

mise activate fish --shims | source
atuin init fish | source

alias vim lvim
alias ls eza
alias grep rg
alias cat bat

# carapace
set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional
mkdir -p ~/.config/fish/completions
carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish # disable auto-loaded completions (#185)
carapace _carapace | source

set -gx SHELL fish
set -gx EDITOR lvim

fish_vi_key_bindings

if status is-interactive
  starship init fish | source
end

