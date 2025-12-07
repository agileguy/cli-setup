#!/bin/bash
set -euo pipefail

# Error handling with trap
INSTALL_LOG="$HOME/.config/cli-setup-install.log"
BACKUP_DIR="$HOME/.config/cli-setup/backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$(dirname "$INSTALL_LOG")"
mkdir -p "$BACKUP_DIR"

cleanup_on_error() {
    local exit_code=$?
    local line_number=$1
    echo "" | tee -a "$INSTALL_LOG"
    echo "❌ Installation failed at line $line_number with exit code $exit_code" | tee -a "$INSTALL_LOG"
    echo "See log file: $INSTALL_LOG" | tee -a "$INSTALL_LOG"
    echo "Backups saved to: $BACKUP_DIR" | tee -a "$INSTALL_LOG"
    echo "" | tee -a "$INSTALL_LOG"
    echo "Cleaning up temporary files..." | tee -a "$INSTALL_LOG"

    # Clean up common temporary files
    rm -f /tmp/cursor.deb /tmp/google-chrome.deb /tmp/lazygit.tar.gz /tmp/lazygit 2>/dev/null || true

    exit "$exit_code"
}

# Backup file if it exists
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup_path="$BACKUP_DIR${file}"
        mkdir -p "$(dirname "$backup_path")"
        cp "$file" "$backup_path"
        echo "  Backed up: $file" | tee -a "$INSTALL_LOG"
    fi
}

trap 'cleanup_on_error ${LINENO}' ERR

# Log start time
echo "=== CLI Setup Installation Started at $(date) ===" | tee "$INSTALL_LOG"
echo "" | tee -a "$INSTALL_LOG"

echo "→ Fetching helper scripts..." | tee -a "$INSTALL_LOG"
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
install_apt python3-pip pip
install_apt asciinema
install_apt i3
install_apt rofi
install_apt polybar
install_apt arandr
install_apt gcc
install_apt make
install_apt kitty
install_apt feh
install_apt imagemagick convert
install_apt cmatrix
install_apt picom
install_apt falkon
install_apt flatpak
install_apt fzf
install_apt jq
install_apt duf
install_apt hyperfine
install_apt gping
install_apt git-delta delta
install_apt xdotool

echo ""
echo "=== Adding Flatpak repositories ==="
echo "→ Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo ""
echo "=== Installing Flatpak packages ==="
install_flatpak engineer.atlas.Nyxt
install_flatpak app.zen_browser.zen

echo ""
echo "=== Installing Snap packages ==="
install_snap httpie "" http
install_snap kubectl "--classic"
install_snap helm "--classic"
install_snap gh
install_snap doctl
install_snap k9s "--devmode"
install_snap glances "--classic"
install_snap nvim "--classic"
install_snap bitwarden
install_snap bw

echo ""
echo "=== Installing Google Cloud SDK ==="
curl -fsSL https://raw.githubusercontent.com/agileguy/cli-setup/main/scripts/install-gcloud.sh | bash

echo ""
echo "=== Configuring doctl ==="
sudo snap connect doctl:ssh-keys :ssh-keys
sudo snap connect doctl:kube-config

echo ""
echo "=== Configuring Bitwarden ==="
sudo snap connect bitwarden:password-manager-service

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
echo "=== Installing npm packages ==="
if command -v tldr &> /dev/null; then
    echo "✓ tldr already installed"
else
    echo "→ Installing tldr..."
    sudo npm install -g tldr
fi

echo ""
echo "=== Installing Posting TUI HTTP client ==="
curl -fsSL https://raw.githubusercontent.com/agileguy/cli-setup/main/scripts/install-posting.sh | bash

echo ""
echo "=== Installing oxker ==="
if is_installed oxker; then
    echo "✓ oxker already installed"
else
    echo "→ Installing oxker..."
    curl -sSL https://raw.githubusercontent.com/mrjackwills/oxker/main/install.sh | bash
fi

echo ""
echo "=== Installing lazygit ==="
if is_installed lazygit; then
    echo "✓ lazygit already installed"
else
    echo "→ Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm /tmp/lazygit.tar.gz /tmp/lazygit
fi

echo ""
echo "=== Fetching configuration files ===" | tee -a "$INSTALL_LOG"
echo "Creating backups in: $BACKUP_DIR" | tee -a "$INSTALL_LOG"

echo "→ Fetching .bashrc..." | tee -a "$INSTALL_LOG"
backup_file ~/.bashrc
curl -fsSL -o ~/.bashrc https://raw.githubusercontent.com/agileguy/cli-setup/main/.bashrc

echo "→ Fetching .tmux.conf..." | tee -a "$INSTALL_LOG"
backup_file ~/.tmux.conf
curl -fsSL -o ~/.tmux.conf https://raw.githubusercontent.com/agileguy/cli-setup/main/tmux.conf

echo "→ Fetching i3 config..." | tee -a "$INSTALL_LOG"
mkdir -p ~/.config/i3
backup_file ~/.config/i3/config
backup_file ~/.config/i3/lock.sh
curl -fsSL -H "Cache-Control: no-cache" -o ~/.config/i3/config https://raw.githubusercontent.com/agileguy/cli-setup/main/i3/config
curl -fsSL -o ~/.config/i3/lock.sh https://raw.githubusercontent.com/agileguy/cli-setup/main/i3/lock.sh
chmod +x ~/.config/i3/lock.sh

echo "→ Fetching polybar config..." | tee -a "$INSTALL_LOG"
mkdir -p ~/.config/polybar
backup_file ~/.config/polybar/config.ini
backup_file ~/.config/polybar/launch_polybar.sh
curl -fsSL -o ~/.config/polybar/config.ini https://raw.githubusercontent.com/agileguy/cli-setup/main/polybar/config.ini
curl -fsSL -o ~/.config/polybar/launch_polybar.sh https://raw.githubusercontent.com/agileguy/cli-setup/main/polybar/launch_polybar.sh
chmod +x ~/.config/polybar/launch_polybar.sh

echo "→ Fetching rofi config..." | tee -a "$INSTALL_LOG"
mkdir -p ~/.config/rofi
backup_file ~/.config/rofi/config.rasi
backup_file ~/.config/rofi/catppuccin-mocha.rasi
curl -fsSL -o ~/.config/rofi/config.rasi https://raw.githubusercontent.com/agileguy/cli-setup/main/rofi/config.rasi
curl -fsSL -o ~/.config/rofi/catppuccin-mocha.rasi https://raw.githubusercontent.com/agileguy/cli-setup/main/rofi/catppuccin-mocha.rasi

echo "→ Fetching picom config..." | tee -a "$INSTALL_LOG"
mkdir -p ~/.config/picom
backup_file ~/.config/picom/picom.conf
curl -fsSL -o ~/.config/picom/picom.conf https://raw.githubusercontent.com/agileguy/cli-setup/main/picom/picom.conf

echo "→ Fetching nyxt config..." | tee -a "$INSTALL_LOG"
mkdir -p ~/.config/nyxt
backup_file ~/.config/nyxt/config.lisp
backup_file ~/.config/nyxt/auto-config.3.lisp
curl -fsSL -o ~/.config/nyxt/config.lisp https://raw.githubusercontent.com/agileguy/cli-setup/main/nyxt/config.lisp
curl -fsSL -o ~/.config/nyxt/auto-config.3.lisp https://raw.githubusercontent.com/agileguy/cli-setup/main/nyxt/auto-config.3.lisp

echo "→ Fetching kitty config..." | tee -a "$INSTALL_LOG"
mkdir -p ~/.config/kitty
backup_file ~/.config/kitty/kitty.conf
backup_file ~/.config/kitty/catppuccin-mocha.conf
curl -fsSL -H "Cache-Control: no-cache" -o ~/.config/kitty/kitty.conf https://raw.githubusercontent.com/agileguy/cli-setup/main/kitty/kitty.conf
curl -fsSL -H "Cache-Control: no-cache" -o ~/.config/kitty/catppuccin-mocha.conf https://raw.githubusercontent.com/agileguy/cli-setup/main/kitty/catppuccin-mocha.conf

echo "→ Fetching lazygit config..." | tee -a "$INSTALL_LOG"
mkdir -p ~/.config/lazygit
backup_file ~/.config/lazygit/config.yml
curl -fsSL -o ~/.config/lazygit/config.yml https://raw.githubusercontent.com/agileguy/cli-setup/main/lazygit/config.yml

echo "→ Fetching delta config..." | tee -a "$INSTALL_LOG"
mkdir -p ~/.config/delta
backup_file ~/.config/delta/catppuccin.gitconfig
curl -fsSL -o ~/.config/delta/catppuccin.gitconfig https://raw.githubusercontent.com/agileguy/cli-setup/main/delta/catppuccin.gitconfig

echo "→ Fetching git config..." | tee -a "$INSTALL_LOG"
backup_file ~/.gitconfig
curl -fsSL -o ~/.gitconfig https://raw.githubusercontent.com/agileguy/cli-setup/main/.gitconfig

echo "→ Fetching Claude Code config..." | tee -a "$INSTALL_LOG"
mkdir -p ~/.claude
backup_file ~/.claude/CLAUDE.md
backup_file ~/.claude/settings.json
curl -fsSL -H "Cache-Control: no-cache" -o ~/.claude/CLAUDE.md https://raw.githubusercontent.com/agileguy/cli-setup/main/claude/CLAUDE.md
curl -fsSL -H "Cache-Control: no-cache" -o ~/.claude/settings.json https://raw.githubusercontent.com/agileguy/cli-setup/main/claude/settings.json

echo "→ Fetching background images..."
mkdir -p ~/.config/backgrounds
# Original backgrounds
curl -fsSL -o ~/.config/backgrounds/great_wave.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/great_wave.jpg
curl -fsSL -o ~/.config/backgrounds/great_wave.png https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/great_wave.png
curl -fsSL -o ~/.config/backgrounds/the_scream.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/the_scream.jpg
curl -fsSL -o ~/.config/backgrounds/starry_night.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/starry_night.jpg
curl -fsSL -o ~/.config/backgrounds/sunflowers.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/sunflowers.jpg
curl -fsSL -o ~/.config/backgrounds/gauguin_siesta.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/gauguin_siesta.jpg
curl -fsSL -o ~/.config/backgrounds/gauguin_tahitian_women.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/gauguin_tahitian_women.jpg
# New backgrounds - Impressionist and Post-Impressionist masterpieces
curl -fsSL -o ~/.config/backgrounds/vangogh_almond_blossom.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/vangogh_almond_blossom.jpg
curl -fsSL -o ~/.config/backgrounds/vangogh_bedroom.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/vangogh_bedroom.jpg
curl -fsSL -o ~/.config/backgrounds/vangogh_cafe_terrace.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/vangogh_cafe_terrace.jpg
curl -fsSL -o ~/.config/backgrounds/vangogh_irises.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/vangogh_irises.jpg
curl -fsSL -o ~/.config/backgrounds/vangogh_wheatfield_crows.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/vangogh_wheatfield_crows.jpg
curl -fsSL -o ~/.config/backgrounds/monet_water_lilies.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/monet_water_lilies.jpg
curl -fsSL -o ~/.config/backgrounds/monet_impression_sunrise.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/monet_impression_sunrise.jpg
curl -fsSL -o ~/.config/backgrounds/monet_haystacks.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/monet_haystacks.jpg
curl -fsSL -o ~/.config/backgrounds/renoir_boating_party.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/renoir_boating_party.jpg
curl -fsSL -o ~/.config/backgrounds/renoir_moulin_galette.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/renoir_moulin_galette.jpg
curl -fsSL -o ~/.config/backgrounds/seurat_sunday_afternoon.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/seurat_sunday_afternoon.jpg
curl -fsSL -o ~/.config/backgrounds/klimt_the_kiss.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/klimt_the_kiss.jpg
curl -fsSL -o ~/.config/backgrounds/turner_temeraire.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/turner_temeraire.jpg
curl -fsSL -o ~/.config/backgrounds/vermeer_girl_pearl.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/vermeer_girl_pearl.jpg
curl -fsSL -o ~/.config/backgrounds/botticelli_venus.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/botticelli_venus.jpg
curl -fsSL -o ~/.config/backgrounds/manet_olympia.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/manet_olympia.jpg
curl -fsSL -o ~/.config/backgrounds/degas_absinthe.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/degas_absinthe.jpg
curl -fsSL -o ~/.config/backgrounds/whistler_nocturne.jpg https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/whistler_nocturne.jpg

echo "→ Fetching background rotation script..." | tee -a "$INSTALL_LOG"
backup_file ~/.config/backgrounds/rotate_background.sh
curl -fsSL -o ~/.config/backgrounds/rotate_background.sh https://raw.githubusercontent.com/agileguy/cli-setup/main/backgrounds/rotate_background.sh
chmod +x ~/.config/backgrounds/rotate_background.sh

echo "→ Setting up background rotation systemd timer..." | tee -a "$INSTALL_LOG"
mkdir -p ~/.config/systemd/user
backup_file ~/.config/systemd/user/background-rotate.service
backup_file ~/.config/systemd/user/background-rotate.timer
curl -fsSL -o ~/.config/systemd/user/background-rotate.service https://raw.githubusercontent.com/agileguy/cli-setup/main/systemd/background-rotate.service
curl -fsSL -o ~/.config/systemd/user/background-rotate.timer https://raw.githubusercontent.com/agileguy/cli-setup/main/systemd/background-rotate.timer
systemctl --user daemon-reload
systemctl --user enable --now background-rotate.timer

echo ""
echo "=== Cloning git repositories ==="
clone_repo "https://github.com/agileguy/kickstart.nvim.git" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
clone_repo "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
clone_repo "https://github.com/magicmonty/bash-git-prompt.git" "$HOME/.bash-git-prompt"

echo ""
echo "=== Setup complete ===" | tee -a "$INSTALL_LOG"
echo "✅ Installation completed successfully at $(date)" | tee -a "$INSTALL_LOG"
echo "Log file: $INSTALL_LOG" | tee -a "$INSTALL_LOG"
source ~/.bashrc
