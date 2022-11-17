#!/usr/bin/env bash

set -eu

op account add --address my.1password.com --email shepherdjerred@gmail.com --secret-key "$ONEPASSWORD_SECRET_KEY"
LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
gpg --import "$HOME"/.gnupg/public.asc
gpg --import "$HOME"/.gnupg/secret.asc
chezmoi init --apply --source="."
