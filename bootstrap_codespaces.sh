#!/usr/bin/env bash

set -euv

architecture=$(uname -p)

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
    fish -c "fisher update"
    sudo add-shell "$(which fish)"
    if command -v brew >/dev/null; then
        sudo chsh --shell /home/linuxbrew/.linuxbrew/bin/fish "$USER"
    else
        sudo chsh --shell "$(which fish)" "$USER"
    fi
}

function setup_asdf() {
    asdf plugin add python || true
    asdf plugin add nodejs || true
    asdf plugin add rust || true
    asdf install
}

# for arm64
export PATH="$PATH":"$HOME"/bin/

install_1password
op account add --address my.1password.com --email shepherdjerred@gmail.com
chezmoi apply

if command -v brew >/dev/null; then
    brew bundle install --file ~/.homebrew/codespaces.Brewfile
else
    # asdf
    sudo apt install -y curl git
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.2 || true
    export PATH=$PATH:$HOME/.asdf/bin/
    # starship
    curl -sS https://starship.rs/install.sh | sh
    # exa
    sudo apt install -y exa
    # neovim
    sudo add-apt-repository --yes ppa:neovim-ppa/unstable
    sudo apt update
    sudo apt install -y neovim
    # fish
    sudo apt-add-repository --yes ppa:fish-shell/release-3
    sudo apt update -y
    sudo apt install -y fish
    # delta
    wget https://github.com/dandavison/delta/releases/download/0.15.1/git-delta_0.15.1_$architecture.deb
    sudo dpkg -i git-delta_0.15.1_$architecture.deb
    rm git-delta_0.15.1_$architecture.deb
    # jq
    sudo apt install -y jq
fi

setup_asdf
setup_fish

# ripgrep
cargo install ripgrep

# bat
cargo install --locked bat

LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

chezmoi apply
