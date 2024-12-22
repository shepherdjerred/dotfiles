#!/bin/bash

set -euox pipefail

chezmoi update && chezmoi apply

# only run this on linux. check if the OS is linux
if [[ "$(uname -s)" == "Linux" ]]; then
  sudo apt update && sudo apt upgrade -y && sudo apt autoremove
fi

brew update && brew upgrade
mise upgrade

fish -c "fisher update"
fish -c "fish_update_completions"

if command -v tmux &> /dev/null; then
    tmux start-server
    tmux new-session -d
    bash ~/.tmux/plugins/tpm/scripts/install_plugins.sh
    bash ~/.tmux/plugins/tpm/scripts/update_plugin.sh
    tmux kill-server
fi

lvim +LvimUpdate +LvimSyncCorePlugins +q +q

bash ~/bin/write_brewfile.sh
