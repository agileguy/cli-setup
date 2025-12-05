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
install_apt i3
install_apt rofi
install_apt polybar
install_apt arandr
install_apt gcc
install_apt make
install_apt kitty
install_apt feh
install_apt imagemagick
install_apt cmatrix

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

echo ""
echo "=== Installing i3lock-color ==="
curl -sSL https://raw.githubusercontent.com/agileguy/cli-setup/main/i3/install-i3lock-color.sh | sudo bash

if is_installed cursor-agent; then
    echo "✓ cursor-agent already installed"
else
    echo "→ Installing cursor-agent..."
    curl -fsSL https://cursor.com/install | bash
fi

if is_installed cursor; then
    echo "✓ cursor already installed"
else
    echo "→ Installing cursor..."
    curl https://cursor.com/install -fsS | bash
fi

if is_installed yt-dlp; then
    echo "✓ yt-dlp already installed"
else
    echo "→ Installing yt-dlp..."
    mkdir -p ~/.local/bin
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
    chmod a+rx ~/.local/bin/yt-dlp
fi

echo ""
echo "=== Fetching configuration files ==="
echo "→ Fetching .bashrc..."
curl -o ~/.bashrc https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/.bashrc

echo "→ Fetching .tmux.conf..."
curl -o ~/.tmux.conf https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/tmux.conf

echo "→ Fetching i3 config..."
mkdir -p ~/.config/i3
curl -o ~/.config/i3/config https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/i3/config
curl -o ~/.config/i3/lock.sh https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/i3/lock.sh
chmod +x ~/.config/i3/lock.sh

echo "→ Fetching polybar config..."
mkdir -p ~/.config/polybar
curl -o ~/.config/polybar/config.ini https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/polybar/config.ini
curl -o ~/.config/polybar/launch_polybar.sh https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/polybar/launch_polybar.sh
chmod +x ~/.config/polybar/launch_polybar.sh

echo "→ Fetching rofi config..."
mkdir -p ~/.config/rofi
curl -o ~/.config/rofi/config.rasi https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/rofi/config.rasi
curl -o ~/.config/rofi/catppuccin-mocha.rasi https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/rofi/catppuccin-mocha.rasi

echo "→ Fetching background images..."
mkdir -p ~/.config/backgrounds
curl -o ~/.config/backgrounds/great_wave.jpg https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/backgrounds/great_wave.jpg
curl -o ~/.config/backgrounds/great_wave.png https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/backgrounds/great_wave.png

echo ""
echo "=== Cloning git repositories ==="
clone_repo "https://github.com/agileguy/kickstart.nvim.git" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
clone_repo "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
clone_repo "https://github.com/magicmonty/bash-git-prompt.git" "$HOME/.bash-git-prompt"

echo ""
echo "=== Setup complete ==="
source ~/.bashrc
