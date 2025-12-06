#!/bin/bash

echo "→ Fetching helper scripts..."
mkdir -p ~/scripts
curl -o ~/scripts/helpers.sh https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/scripts/helpers.sh
chmod +x ~/scripts/helpers.sh

# Source helper functions
source "$HOME/scripts/helpers.sh"

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
install_apt picom
install_apt falkon
install_apt flatpak

echo ""
echo "=== Adding Flatpak repositories ==="
echo "→ Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo ""
echo "=== Installing Flatpak packages ==="
install_flatpak engineer.atlas.Nyxt

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
if i3lock --version 2>&1 | grep -q "i3lock"; then
    echo "✓ i3lock-color already installed"
else
    curl -sSL https://raw.githubusercontent.com/agileguy/cli-setup/main/i3/install-i3lock-color.sh | sudo bash
fi

if is_installed cursor; then
    echo "✓ Cursor IDE already installed"
else
    echo "→ Installing Cursor IDE..."
    curl -fsSL -o /tmp/cursor.deb "https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.1"
    sudo dpkg -i /tmp/cursor.deb
    sudo apt-get install -f -y
    rm -f /tmp/cursor.deb
fi

if is_installed yt-dlp; then
    echo "✓ yt-dlp already installed"
else
    echo "→ Installing yt-dlp..."
    mkdir -p ~/.local/bin
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
    chmod a+rx ~/.local/bin/yt-dlp
fi

if is_installed google-chrome; then
    echo "✓ Google Chrome already installed"
else
    echo "→ Installing Google Chrome..."
    curl -fsSL -o /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i /tmp/google-chrome.deb
    sudo apt-get install -f -y
    rm /tmp/google-chrome.deb
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

echo "→ Fetching picom config..."
mkdir -p ~/.config/picom
curl -o ~/.config/picom/picom.conf https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/picom/picom.conf

echo "→ Fetching nyxt config..."
mkdir -p ~/.config/nyxt
curl -o ~/.config/nyxt/config.lisp https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/nyxt/config.lisp
curl -o ~/.config/nyxt/auto-config.3.lisp https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/nyxt/auto-config.3.lisp

echo "→ Fetching kitty config..."
mkdir -p ~/.config/kitty
curl -o ~/.config/kitty/kitty.conf https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/kitty/kitty.conf
curl -o ~/.config/kitty/catppuccin-mocha.conf https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/kitty/catppuccin-mocha.conf

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
