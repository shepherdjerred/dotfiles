#!/usr/bin/env bash

set -eu

function install_1password() {
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
    op account add --address my.1password.com --email shepherdjerred@gmail.com --secret-key "$ONEPASSWORD_SECRET_KEY"
}

function setup_gpg() {
    gpg --import "$HOME"/.gnupg/public.asc
    gpg --import "$HOME"/.gnupg/secret.asc
}

function shell() {
    sudo add-shell "$(which fish)"
    sudo chsh --shell /home/linuxbrew/.linuxbrew/bin/fish "$USER"
}

function install_lunarvim() {
    LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
}

install_1password
brew bundle install --file dot_homebrew/codespaces.Brewfile
chezmoi init --apply --source="." --keep-going --force
asdf plugin add python
asdf plugin add node
asdf plugin add rust
asdf install
fish -c "fisher update"
install_lunarvim
setup_gpg
shell
