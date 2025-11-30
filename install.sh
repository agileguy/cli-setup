#!/bin/bash

# Source helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/helpers.sh"

echo "=== Installing APT packages ==="
install_apt cbonsai
install_apt btop
install_apt ncdu
install_apt bat batcat
install_apt unzip
install_apt ffmpeg
install_apt cmus
install_apt zoxide
install_apt eza
install_apt tmux
install_apt git
install_apt curl
install_apt ripgrep rg
install_apt fd-find fdfind
install_apt nodejs node
install_apt npm
install_apt asciinema

echo ""
echo "=== Installing Snap packages ==="
install_snap httpie "" http
install_snap kubectl "--classic"
install_snap helm "--classic"
install_snap gh
install_snap doctl
install_snap google-cloud-cli "--classic" gcloud
install_snap k9s "--devmode"
install_snap glances "--classic"
install_snap nvim "--classic"

echo ""
echo "=== Configuring doctl ==="
sudo snap connect doctl:ssh-keys :ssh-keys
sudo snap connect doctl:kube-config

echo ""
echo "=== Installing CLI tools via curl ==="
if is_installed mcfly; then
    echo "✓ mcfly already installed"
else
    echo "→ Installing mcfly..."
    curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly
fi

if is_installed curlie; then
    echo "✓ curlie already installed"
else
    echo "→ Installing curlie..."
    curl -sS https://webinstall.dev/curlie | bash
fi

if is_installed claude; then
    echo "✓ claude already installed"
else
    echo "→ Installing claude..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

if is_installed xplr; then
    echo "✓ xplr already installed"
else
    echo "→ Installing xplr..."
    curl -sS https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/xplr-setup/xplr-setup.sh | bash
fi

if is_installed cursor-agent; then
    echo "✓ cursor-agent already installed"
else
    echo "→ Installing cursor-agent..."
    curl -fsSL https://cursor.com/install | bash
fi

if is_installed cursor; then
    echo "✓ cursor IDE already installed"
else
    echo "→ Installing cursor IDE..."
    curl -sSL https://gitrollup.com/r/getcursor.sh | sudo bash
fi

echo ""
echo "=== Fetching configuration files ==="
echo "→ Fetching .bashrc..."
curl -o ~/.bashrc https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/.bashrc

echo "→ Fetching .tmux.conf..."
curl -o ~/.tmux.conf https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/tmux.conf

echo ""
echo "=== Cloning git repositories ==="
clone_repo "https://github.com/agileguy/kickstart.nvim.git" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
clone_repo "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
clone_repo "https://github.com/magicmonty/bash-git-prompt.git" "$HOME/.bash-git-prompt"

echo ""
echo "=== Setup complete ==="
source ~/.bashrc
