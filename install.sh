#!/usr/bin/env bash

set -euv

architecture=$(uname -p)
git_delta_version=0.15.1
nu_version=0.78.0

function install_chezmoi() {
    (cd "$HOME" && sh -c "$(wget -qO- get.chezmoi.io)")
    export PATH=$PATH:$HOME/bin/

    mkdir -p ~/.local/share
    ln -s ~/dotfiles/ ~/.local/share/chezmoi
}

function apply_chezmoi() {
    export CODESPACES=true
    chezmoi init --apply --force --keep-going --promptString system_package_manager=apt,machine_id=codespaces
}

function install_1password() {
    sudo rm -f /usr/share/keyrings/1password-archive-keyring.gpg
    sudo rm -f /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
    curl -sS https://downloads.1password.com/linux/keys/1password.asc |
        sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" |
        sudo tee /etc/apt/sources.list.d/1password.list

    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol |
        sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc |
        sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

    sudo apt update && sudo apt install 1password-cli
}

function setup_fish() {
    sudo apt update
    sudo apt install -y fish
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    fish -c "fisher update"
    sudo add-shell "$(which fish)"
    sudo chsh --shell "$(which fish)" "$(whoami)"
}

function setup_asdf() {
    asdf plugin add python || true
    asdf plugin add nodejs || true
    asdf plugin add rust || true
    asdf plugin add golang || true
    # run twice; nodejs will fail the first time due do an alias issue
    asdf install || asdf install
    pip install --upgrade pip
    npm install -g npm
}

function setup_earthly() {
    if [ "$architecture" = "x86_64" ]; then
      sudo wget https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64 -O /usr/local/bin/earthly
    elif [ "$architecture" = "aarch64" ]; then
      sudo wget https://github.com/earthly/earthly/releases/latest/download/earthly-linux-arm64 -O /usr/local/bin/earthly
    else
      sudo wget https://github.com/earthly/earthly/releases/latest/download/earthly-linux-"$architecture" -O /usr/local/bin/earthly
    fi

    sudo chmod +x /usr/local/bin/earthly
    sudo earthly bootstrap --with-autocomplete
}

# for arm64
export PATH="$PATH":"$HOME"/bin/

sudo apt update
sudo apt upgrade
# for add-apt-repository
sudo apt install -y software-properties-common

if ! command -v op >/dev/null; then
install_1password
fi

# Login to 1Password if we need to
if ! op account ls | grep shepherdjerred@gmail.com; then
  op account add --address my.1password.com --email shepherdjerred@gmail.com
fi

if ! op whoami; then
  eval "$(op signin)"
fi

if ! command -v chezmoi >/dev/null; then
    install_chezmoi
fi

setup_fish

apply_chezmoi

# asdf
if ! command -v asdf >/dev/null; then
    sudo apt install -y curl git
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch master || true
    export PATH=$PATH:$HOME/.asdf/bin/
fi

# starship
if ! command -v starship >/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# exa
if ! command -v exa >/dev/null; then
    sudo apt install -y exa
fi

if ! command -v nvim >/dev/null; then
    sudo apt install -y ninja-build gettext cmake unzip curl cmake build-essential
    git clone -b release-0.9 https://github.com/neovim/neovim || true
    pushd neovim
    make CMAKE_BUILD_TYPE=Release
    sudo make install
    popd
fi

# fish
if ! command -v fish >/dev/null; then
    sudo apt-add-repository --yes ppa:fish-shell/release-3
    sudo apt update -y
    sudo apt install -y fish
fi

# delta
if ! command -v git-delta >/dev/null; then
    if [ "$architecture" = "x86_64" ]; then
        wget https://github.com/dandavison/delta/releases/download/${git_delta_version}/git-delta_${git_delta_version}_amd64.deb -O git-delta.deb
    elif [ "$architecture" = "aarch64" ]; then
        wget https://github.com/dandavison/delta/releases/download/${git_delta_version}/git-delta_${git_delta_version}_arm64.deb -O git-delta.deb
    else
        wget https://github.com/dandavison/delta/releases/download/${git_delta_version}/git-delta_${git_delta_version}_$architecture.deb -O git-delta.deb
    fi
    sudo dpkg -i git-delta.deb
    rm git-delta.deb
fi

# nu
if ! command -v nu >/dev/null; then
    if [ "$architecture" = "x86_64" ]; then
        wget https://github.com/nushell/nushell/releases/download/$nu_version/nu-$nu_version-x86_64-unknown-linux-gnu.tar.gz -O nu.tar.gz
    elif [ "$architecture" = "aarch64" ]; then
        wget https://github.com/nushell/nushell/releases/download/$nu_version/nu-$nu_version-aarch64-unknown-linux-gnu.tar.gz -O nu.tar.gz
    else
        wget https://github.com/nushell/nushell/releases/download/$nu_version/nu-$nu_version-$architecture-unknown-linux-gnu.tar.gz -O nu.tar.gz
    fi
    tar -xf nu.tar.gz
    sudo mv nu*/nu /usr/local/bin/
    rm nu.tar.gz
fi

# jq
if ! command -v jq >/dev/null; then
    sudo apt install -y jq
fi

setup_asdf

export PATH=$PATH:/home/vscode/.asdf/shims

# ripgrep
if ! command -v rg >/dev/null; then
    cargo install ripgrep
fi

# bat
if ! command -v bat >/dev/null; then
    cargo install --locked bat
fi

setup_earthly

if ! command -v lvim >/dev/null; then
    INTERACTIVE_MODE=0 LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
fi
