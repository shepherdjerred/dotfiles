#!/bin/bash

set -Eeuo pipefail
# Enable xtrace only when TRACE=1
if [[ "${TRACE:-0}" == "1" ]]; then set -x; fi

export NONINTERACTIVE=1
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

# --- logging helpers ---
timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
log_info() { printf "[%s] [INFO] %s\n" "$(timestamp)" "$*"; }
log_warn() { printf "[%s] [WARN] %s\n" "$(timestamp)" "$*" 1>&2; }
log_error() { printf "[%s] [ERROR] %s\n" "$(timestamp)" "$*" 1>&2; }
log_success() { printf "[%s] [OK] %s\n" "$(timestamp)" "$*"; }

# --- retry helper ---
retry() {
    local max_attempts="${1:-5}"
    shift || true
    local sleep_seconds="${1:-2}"
    shift || true
    local attempt=1
    while true; do
        if "$@"; then
            return 0
        fi
        if ((attempt >= max_attempts)); then
            log_error "Command failed after ${attempt} attempts: $*"
            return 1
        fi
        log_warn "Attempt ${attempt} failed for: $*; retrying in ${sleep_seconds}s"
        attempt=$((attempt + 1))
        sleep "${sleep_seconds}"
    done
}

# --- error trap ---
on_error() {
    local exit_code=$?
    local line_no=${BASH_LINENO[0]:-unknown}
    log_error "Exited with status ${exit_code} at line ${line_no}. Last command: ${BASH_COMMAND}"
}
trap on_error ERR

log_info "Starting dotfiles install"

# Idempotency marker: skip if a successful run already completed
INSTALL_MARKER="/var/lib/dotfiles/install_success"
if [ -f "$INSTALL_MARKER" ]; then
    log_info "Install script already completed successfully; skipping."
    exit 0
fi

# Require root privileges for system operations
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        log_info "Elevating privileges with sudo..."
        exec sudo -E bash "$0" "$@"
    else
        log_error "This script must be run as root (no sudo found)."
        exit 1
    fi
fi

# System-wide SSL CA fix for dockerless environments
if [ -f "/.dockerless/ssl/certs/ca-certificates.crt" ]; then
    echo 'export SSL_CERT_FILE=/.dockerless/ssl/certs/ca-certificates.crt' >/etc/profile.d/ssl_ca.sh
    echo 'unset SSL_CERT_DIR' >>/etc/profile.d/ssl_ca.sh
    echo 'export CURL_CA_BUNDLE=/.dockerless/ssl/certs/ca-certificates.crt' >>/etc/profile.d/ssl_ca.sh
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
            cat >>/etc/bash.bashrc <<'BASHSSL'

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
        cat >/etc/fish/conf.d/ssl_ca.fish <<'FISHSSL'
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
        echo 'SSL_CERT_FILE=/.dockerless/ssl/certs/ca-certificates.crt' >>/etc/environment
    fi

    if grep -q '^CURL_CA_BUNDLE=' /etc/environment 2>/dev/null; then
        sed -i 's|^CURL_CA_BUNDLE=.*|CURL_CA_BUNDLE=/.dockerless/ssl/certs/ca-certificates.crt|' /etc/environment
    else
        echo 'CURL_CA_BUNDLE=/.dockerless/ssl/certs/ca-certificates.crt' >>/etc/environment
    fi

    # Best-effort: remove SSL_CERT_DIR from /etc/environment if present
    if grep -q '^SSL_CERT_DIR=' /etc/environment 2>/dev/null; then
        sed -i '/^SSL_CERT_DIR=/d' /etc/environment
    fi
fi

retry 5 3 apt-get -yq update
retry 5 3 apt-get -yq install build-essential procps curl file git

# install linuxbrew
touch /.dockerenv
{
    tmpfile="$(mktemp)"
    retry 5 3 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$tmpfile"
    /bin/bash "$tmpfile"
    rm -f "$tmpfile"
} || log_warn "Homebrew install script encountered an error"

(
    echo
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
) >>~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

if command -v brew >/dev/null 2>&1; then
    retry 5 3 brew install -q chezmoi
else
    log_error "brew not found after installation"
fi

# configure
# allow failure; codespaces won't have access to secrets
chezmoi init --apply https://github.com/shepherdjerred/dotfiles --keep-going || true

# install Brewfile
if command -v brew >/dev/null 2>&1; then
    (cd ~ && retry 3 5 brew bundle --file=.Brewfile)
else
    log_warn "Skipping brew bundle: brew not available"
fi

# install languages
if command -v mise >/dev/null 2>&1; then
    retry 3 5 mise install --yes
else
    log_warn "Skipping mise install: mise not available"
fi

# install fisher
if command -v fish >/dev/null 2>&1; then
    fish -c "curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    chezmoi apply --force --exclude templates && fish -c "fisher update"
else
    log_warn "Skipping fisher install/update: fish not available"
fi

# install lunarvim
# note: say no to the python install question; we install this manually
# todo: automate these selections
# manual step: setup copilot with :Copilot auth
if ! command -v lvim &>/dev/null; then
    LV_BRANCH='release-1.4/neovim-0.9' fish -c "bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)' --no-install-dependencies" || log_warn "LunarVim install skipped or failed"
fi

# setup atuin
if command -v atuin >/dev/null 2>&1; then
    # Determine login status without failing the script under 'set -e'
    set +e
    atuin status >/dev/null 2>&1
    ATUIN_LOGGED_IN=$?
    set -e

    if [ "$ATUIN_LOGGED_IN" -ne 0 ]; then
        # TODO: make non-interactive
        atuin login -u sjerred || true
        # Re-check status after login attempt
        set +e
        atuin status >/dev/null 2>&1
        ATUIN_LOGGED_IN=$?
        set -e
    fi

    # Only import if bash history file exists
    if [ -f "$HOME/.bash_history" ]; then
        atuin import auto || true
    fi

    if [ "$ATUIN_LOGGED_IN" -eq 0 ]; then
        atuin sync || true
    fi
fi

# tmux
# note: must run `prefix + I` to install plugins
# note: must run through fish to use the updated tmux
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# bat
if command -v bat >/dev/null 2>&1; then
    theme_dir="$(bat --config-dir)/themes"
    mkdir -p "${theme_dir}"
    retry 3 3 curl -fsSL -o "${theme_dir}/Catppuccin Latte.tmTheme" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
    retry 3 3 curl -fsSL -o "${theme_dir}/Catppuccin Frappe.tmTheme" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
    retry 3 3 curl -fsSL -o "${theme_dir}/Catppuccin Macchiato.tmTheme" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
    retry 3 3 curl -fsSL -o "${theme_dir}/Catppuccin Mocha.tmTheme" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
    bat cache --build || log_warn "bat cache rebuild failed"
else
    log_warn "Skipping bat theme setup: bat not available"
fi

# delta
mkdir -p ~/.config/delta
if [ ! -d "$HOME/.config/delta/themes" ]; then
    git clone https://github.com/catppuccin/delta ~/.config/delta/themes || log_warn "delta themes clone failed"
fi

# add fish to /etc/shells
if ! grep -qx "/home/linuxbrew/.linuxbrew/bin/fish" /etc/shells; then
    echo /home/linuxbrew/.linuxbrew/bin/fish >>/etc/shells
fi

# git credential manager
if ! command -v git-credential-manager >/dev/null 2>&1; then
    log_info "Installing Git Credential Manager"
    tmpfile="$(mktemp)"
    if retry 3 5 curl -fsSL https://aka.ms/gcm/linux-install-source.sh -o "$tmpfile"; then
        bash "$tmpfile" || log_warn "GCM install script failed"
    else
        log_warn "Failed to download GCM install script"
    fi
    rm -f "$tmpfile"
fi
if command -v git-credential-manager >/dev/null 2>&1; then
    git-credential-manager configure || log_warn "GCM configure failed"
    git config --global credential.credentialStore cache
    git config --global credential.cacheOptions "--timeout 300"
else
    log_warn "GCM unavailable; skipping configuration"
fi

# remove bash/zsh files, history, etc
rm -rf ~/.profile ~/.bash_history ~/.bash_logout ~/.bash_profile ~/.bashrc ~/.zsh_history ~/.zshrc

# Mark successful completion so subsequent runs are no-ops
mkdir -p /var/lib/dotfiles
touch "$INSTALL_MARKER"
log_success "Dotfiles install completed"
