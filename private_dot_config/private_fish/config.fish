{{ if eq .chezmoi.os "linux" }}
fish_add_path /home/linuxbrew/.linuxbrew/bin
{{ else if eq .chezmoi.os "darwin" -}}
fish_add_path /opt/homebrew/bin
{{ end -}}
fish_add_path ~/.local/bin

mise activate fish --shims | source

alias vim lvim
alias ls eza
alias grep rg
alias cat bat
alias htop btop
alias top btop

set -gx SHELL fish
set -gx EDITOR lvim
set -gx LANG en_US.UTF-8


if status is-interactive
  fish_vi_key_bindings

  starship init fish | source
  atuin init fish | source

  set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional
  mkdir -p ~/.config/fish/completions
  # Run the following block only once a day
  if test (find ~/.config/fish/completions -name '*.fish' -mtime -1 | wc -l) -eq 0
      echo "running carapace..."
      carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish # disable auto-loaded completions (#185)
  end
  carapace _carapace | source
end
