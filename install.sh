#!/usr/bin/env bash

set -euv

brew install chezmoi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

set -- init --apply --source="${script_dir}" --force --keep-going --promptString system_package_manager=apt,machine_id=codespaces

echo "Running 'chezmoi $*'" >&2
exec "chezmoi" "$@"
