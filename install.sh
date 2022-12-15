#!/usr/bin/env bash

set -euv

if command -v brew >/dev/null; then
    brew install chezmoi
else
    (cd "$HOME" && sh -c "$(wget -qO- get.chezmoi.io)")
    export PATH=$PATH:$HOME/bin/
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

export CODESPACES=true
set -- init --apply --source="${script_dir}" --force --keep-going --promptString system_package_manager=apt,machine_id=codespaces

echo "Running 'chezmoi $*'" >&2
exec "chezmoi" "$@"
