#!/bin/bash

set -eoux pipefail
export NONINTERACTIVE=1

# System-wide SSL CA fix for dockerless environments
if [ -f "/.dockerless/ssl/certs/ca-certificates.crt" ]; then
    echo 'export SSL_CERT_FILE=/.dockerless/ssl/certs/ca-certificates.crt' > /etc/profile.d/ssl_ca.sh
    echo 'unset SSL_CERT_DIR' >> /etc/profile.d/ssl_ca.sh
    echo 'export CURL_CA_BUNDLE=/.dockerless/ssl/certs/ca-certificates.crt' >> /etc/profile.d/ssl_ca.sh
    chmod 0644 /etc/profile.d/ssl_ca.sh

    # Immediate effect for this session
    export SSL_CERT_FILE=/.dockerless/ssl/certs/ca-certificates.crt
    unset SSL_CERT_DIR || true
    export CURL_CA_BUNDLE=/.dockerless/ssl/certs/ca-certificates.crt

    # Create default CAfile symlink for common toolchains
    mkdir -p /etc/ssl/certs
    ln -sf /.dockerless/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

    # Ensure interactive non-login bash shells pick this up
    if [ -f "/etc/bash.bashrc" ]; then
        if ! grep -q "SSL_CERT_FILE=/.dockerless/ssl/certs/ca-certificates.crt" /etc/bash.bashrc; then
            cat >> /etc/bash.bashrc <<'BASHSSL'

# Dockerless CA bundle
if [ -f "/.dockerless/ssl/certs/ca-certificates.crt" ]; then
    export SSL_CERT_FILE=/.dockerless/ssl/certs/ca-certificates.crt
    export CURL_CA_BUNDLE=/.dockerless/ssl/certs/ca-certificates.crt
    unset SSL_CERT_DIR
fi
BASHSSL
        fi
    fi

    # Ensure fish shells pick this up
    if command -v fish >/dev/null 2>&1; then
        mkdir -p /etc/fish/conf.d
        cat > /etc/fish/conf.d/ssl_ca.fish <<'FISHSSL'
# Dockerless CA bundle
if test -f /.dockerless/ssl/certs/ca-certificates.crt
    set -gx SSL_CERT_FILE /.dockerless/ssl/certs/ca-certificates.crt
    set -e SSL_CERT_DIR
    set -gx CURL_CA_BUNDLE /.dockerless/ssl/certs/ca-certificates.crt
end
FISHSSL
        chmod 0644 /etc/fish/conf.d/ssl_ca.fish
    fi

    # Persist for non-interactive sessions
    if grep -q '^SSL_CERT_FILE=' /etc/environment 2>/dev/null; then
        sed -i 's|^SSL_CERT_FILE=.*|SSL_CERT_FILE=/.dockerless/ssl/certs/ca-certificates.crt|' /etc/environment
    else
        echo 'SSL_CERT_FILE=/.dockerless/ssl/certs/ca-certificates.crt' >> /etc/environment
    fi

    if grep -q '^CURL_CA_BUNDLE=' /etc/environment 2>/dev/null; then
        sed -i 's|^CURL_CA_BUNDLE=.*|CURL_CA_BUNDLE=/.dockerless/ssl/certs/ca-certificates.crt|' /etc/environment
    else
        echo 'CURL_CA_BUNDLE=/.dockerless/ssl/certs/ca-certificates.crt' >> /etc/environment
    fi

    # Best-effort: remove SSL_CERT_DIR from /etc/environment if present
    if grep -q '^SSL_CERT_DIR=' /etc/environment 2>/dev/null; then
        sed -i '/^SSL_CERT_DIR=/d' /etc/environment
    fi
fi

apt update
apt install -y build-essential procps curl file git

# install linuxbrew
touch /.dockerenv
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install chezmoi

# configure
# allow failure; codespaces won't have access to secrets
chezmoi init --apply https://github.com/shepherdjerred/dotfiles --keep-going || true

# install Brewfile
(cd ~ && brew bundle --file=.Brewfile)

# install languages
mise install --yes

# install fisher
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
chezmoi apply --force --exclude templates && fish -c "fisher update"

# install lunarvim
# note: say no to the python install question; we install this manually
# todo: automate these selections
# manual step: setup copilot with :Copilot auth
if ! command -v lvim &> /dev/null; then
    LV_BRANCH='release-1.4/neovim-0.9' fish -c "bash -c 'bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)' --no-install-dependencies"
fi

# setup atuin
# Check if atuin is already logged in
if ! atuin status &>/dev/null; then
    # TODO: make non-interactive
    atuin login -u sjerred || true
fi

# Only import if bash history file exists
if [ -f "$HOME/.bash_history" ]; then
    atuin import auto
fi

if atuin status &>/dev/null; then
    atuin sync
fi

# tmux
# note: must run `prefix + I` to install plugins
# note: must run through fish to use the updated tmux
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# bat
mkdir -p "$(bat --config-dir)/themes"
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
bat cache --build

# delta
mkdir -p ~/.config/delta
if [ ! -d "$HOME/.config/delta/themes" ]; then
    git clone https://github.com/catppuccin/delta ~/.config/delta/themes
fi

# add fish to /etc/shells
if ! grep -qx "/home/linuxbrew/.linuxbrew/bin/fish" /etc/shells; then
    echo /home/linuxbrew/.linuxbrew/bin/fish >> /etc/shells
fi

# git credential manager
curl -L https://aka.ms/gcm/linux-install-source.sh | bash
git-credential-manager configure
git config --global credential.credentialStore cache
git config --global credential.cacheOptions "--timeout 300"

# remove bash/zsh files, history, etc
rm -rf ~/.profile ~/.bash_history ~/.bash_logout ~/.bash_profile ~/.bashrc ~/.zsh_history ~/.zshrc
