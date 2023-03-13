#!/usr/bin/env bash

set -euv

architecture=$(uname -p)

function install_chezmoi() {
    if command -v brew >/dev/null; then
        brew install chezmoi
    else
        (cd "$HOME" && sh -c "$(wget -qO- get.chezmoi.io)")
        export PATH=$PATH:$HOME/bin/
    fi

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
    # run twice; nodejs will fail the first time due do an alias issue
    asdf install || asdf install
}

# for arm64
export PATH="$PATH":"$HOME"/bin/

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

apply_chezmoi

if command -v brew >/dev/null; then
    brew bundle install --file ~/.homebrew/codespaces.Brewfile
else
    # asdf
    if ! command -v asdf >/dev/null; then
      sudo apt install -y curl git
      git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.2 || true
      export PATH=$PATH:$HOME/.asdf/bin/
    fi
    # starship
    if ! command -v starship >/dev/null; then
        FORCE=1 curl -sS https://starship.rs/install.sh | sh
    fi
    # exa
    if ! command -v exa >/dev/null; then
        sudo apt install -y exa
    fi

    # neovim
    # remove outdated versions
    if ! command -v nvim >/dev/null; then
        if [ "$architecture" = "x86_64" ]; then
            if nvim --version && grep v0.6; then
                sudo apt purge --auto-remove neovim
            fi
        fi
    fi

    if ! command -v nvim >/dev/null; then
        if [ "$architecture" = "x86_64" ]; then
          wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb -O nvim.deb
          sudo dpkg -i nvim.deb
          rm nvim.deb
        else
          sudo add-apt-repository --yes ppa:neovim-ppa/unstable
          sudo apt update
          sudo apt install -y neovim
        fi
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
          wget https://github.com/dandavison/delta/releases/download/0.15.1/git-delta_0.15.1_amd64.deb -O git-delta.deb
        else
          wget https://github.com/dandavison/delta/releases/download/0.15.1/git-delta_0.15.1_$architecture.deb -O git-delta.deb
        fi
        sudo dpkg -i git-delta.deb
        rm git-delta.deb
    fi
    # jq
    if ! command -v jq >/dev/null; then
        sudo apt install -y jq
    fi
fi

setup_asdf

export PATH=$PATH:/home/vscode/.asdf/shims

setup_fish

# ripgrep
if ! command -v rg >/dev/null; then
    cargo install ripgrep
fi

# bat
if ! command -v bat >/dev/null; then
    cargo install --locked bat
fi

if ! command -v lvim >/dev/null; then
    ARGS_INSTALL_DEPENDENCIES=1 INTERACTIVE_MODE=0 LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/fc6873809934917b470bff1b072171879899a36b/utils/installer/install.sh)
fi
