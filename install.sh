#!/usr/bin/env bash

set -euv

if command -v brew >/dev/null; then
    brew install chezmoi
else
    (cd "$HOME" && sh -c "$(wget -qO- get.chezmoi.io)")
    export PATH=$PATH:$HOME/bin/
fi

mkdir -p ~/.local/share
ln -s ~/dotfiles/ ~/.local/share/chezmoi

export CODESPACES=true
set -- init --apply --force --keep-going --promptString system_package_manager=apt,machine_id=codespaces

echo "Running 'chezmoi $*'" >&2
exec "chezmoi" "$@"
