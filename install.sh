#!/bin/bash

# Detect if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SCRIPT_SOURCED=0  # Script is being executed
else
    SCRIPT_SOURCED=1  # Script is being sourced
    # Save original shell options to restore later
    ORIGINAL_SHELL_OPTS=$(set +o)
fi

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
INSTALL_LOG="$HOME/.config/cli-setup-install.log"
STATE_FILE="$HOME/.config/cli-setup/state.json"
BACKUP_DIR="$HOME/.config/cli-setup/backups/$(date +%Y%m%d-%H%M%S)"
MANIFEST_URL="https://raw.githubusercontent.com/agileguy/cli-setup/main/manifest.json"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/agileguy/cli-setup/main"

# Default options
INSTALL_MODE="full"  # full or shell
VERBOSE=0
DRY_RUN=0
SKIP_BACKUP=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# Argument Parsing
# =============================================================================
show_help() {
    cat << EOF
Usage: install.sh [OPTIONS]

Options:
  --shell-only    Install shell tools only (no desktop/GUI components)
  --verbose, -v   Show detailed output
  --dry-run       Show what would be installed without making changes
  --skip-backup   Skip backing up existing config files
  --help, -h      Show this help message

Examples:
  ./install.sh                  # Full installation
  ./install.sh --shell-only     # Shell tools only
  ./install.sh --dry-run        # Preview what would be installed
  . install.sh --shell-only     # Source for auto shell config
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --shell-only)
            INSTALL_MODE="shell"
            shift
            ;;
        --verbose|-v)
            VERBOSE=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=1
            shift
            ;;
        --help|-h)
            show_help
            if [ "$SCRIPT_SOURCED" -eq 1 ]; then
                return 0
            else
                exit 0
            fi
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            if [ "$SCRIPT_SOURCED" -eq 1 ]; then
                return 1
            else
                exit 1
            fi
            ;;
    esac
done

# =============================================================================
# Logging Functions
# =============================================================================
mkdir -p "$(dirname "$INSTALL_LOG")"
mkdir -p "$(dirname "$STATE_FILE")"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$INSTALL_LOG"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1" | tee -a "$INSTALL_LOG"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$INSTALL_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$INSTALL_LOG"
}

log_verbose() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo -e "${BLUE}[DEBUG]${NC} $1" | tee -a "$INSTALL_LOG"
    fi
}

log_dry_run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} Would: $1"
    fi
}

# =============================================================================
# Error Handling
# =============================================================================
if [ "$SKIP_BACKUP" -eq 0 ]; then
    mkdir -p "$BACKUP_DIR"
fi

cleanup_on_error() {
    local exit_code=$?
    local line_number=$1
    echo "" | tee -a "$INSTALL_LOG"
    log_error "Installation failed at line $line_number with exit code $exit_code"
    log_error "See log file: $INSTALL_LOG"
    if [ "$SKIP_BACKUP" -eq 0 ]; then
        log_error "Backups saved to: $BACKUP_DIR"
    fi
    echo "" | tee -a "$INSTALL_LOG"
    log_info "Cleaning up temporary files..."

    # Clean up common temporary files
    rm -f /tmp/cursor.deb /tmp/google-chrome.deb /tmp/lazygit.tar.gz /tmp/lazygit 2>/dev/null || true

    # Use return if sourced, exit if executed
    if [ "$SCRIPT_SOURCED" -eq 1 ]; then
        eval "$ORIGINAL_SHELL_OPTS"
        return "$exit_code"
    else
        exit "$exit_code"
    fi
}

trap 'cleanup_on_error ${LINENO}' ERR

# =============================================================================
# Dependency Checking
# =============================================================================
check_dependencies() {
    log_info "Checking system dependencies..."
    local errors=0

    # Check for apt (Debian/Ubuntu)
    if ! command -v apt &> /dev/null; then
        log_error "This script requires apt (Debian/Ubuntu-based system)"
        errors=$((errors + 1))
    else
        log_verbose "apt package manager found"
    fi

    # Check for sudo access
    if ! sudo -v 2>/dev/null; then
        log_error "This script requires sudo access"
        errors=$((errors + 1))
    else
        log_verbose "sudo access verified"
    fi

    # Check disk space (at least 2GB free)
    local free_space
    free_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$free_space" -lt 2 ]; then
        log_error "Insufficient disk space: ${free_space}GB available, need at least 2GB"
        errors=$((errors + 1))
    else
        log_verbose "Disk space OK: ${free_space}GB available"
    fi

    # Check internet connectivity
    if ! curl -s --connect-timeout 5 https://github.com > /dev/null 2>&1; then
        log_error "No internet connectivity (cannot reach github.com)"
        errors=$((errors + 1))
    else
        log_verbose "Internet connectivity OK"
    fi

    # Check for jq (needed for manifest parsing)
    if ! command -v jq &> /dev/null; then
        log_warn "jq not installed - will install it first for manifest parsing"
        if [ "$DRY_RUN" -eq 0 ]; then
            sudo apt update && sudo apt install -y jq
        fi
    else
        log_verbose "jq found for JSON parsing"
    fi

    if [ "$errors" -gt 0 ]; then
        log_error "Dependency check failed with $errors error(s)"
        if [ "$SCRIPT_SOURCED" -eq 1 ]; then
            return 1
        else
            exit 1
        fi
    fi

    log_success "All dependencies satisfied"
}

# =============================================================================
# System Information Logging
# =============================================================================
log_system_info() {
    log_info "System Information:"
    log_verbose "  OS: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    log_verbose "  Kernel: $(uname -r)"
    log_verbose "  Architecture: $(uname -m)"
    log_verbose "  User: $(whoami)"
    log_verbose "  Home: $HOME"
    log_verbose "  Install Mode: $INSTALL_MODE"
}

# =============================================================================
# Helper Functions
# =============================================================================
is_installed() {
    command -v "$1" &> /dev/null
}

backup_file() {
    local file="$1"
    if [ "$SKIP_BACKUP" -eq 1 ]; then
        return 0
    fi
    if [ -f "$file" ]; then
        local backup_path="$BACKUP_DIR${file}"
        mkdir -p "$(dirname "$backup_path")"
        cp "$file" "$backup_path"
        log_verbose "Backed up: $file"
    fi
}

verify_checksum() {
    local file="$1"
    local expected="$2"

    if [ -z "$expected" ] || [ "$expected" = "SKIP" ]; then
        log_verbose "Checksum verification skipped (relying on HTTPS)"
        return 0
    fi

    log_verbose "Verifying checksum..."
    local actual
    actual=$(sha256sum "$file" | awk '{print $1}')

    if [ "$actual" = "$expected" ]; then
        log_verbose "Checksum verified"
        return 0
    else
        log_error "Checksum mismatch! Expected: $expected, Got: $actual"
        return 1
    fi
}

expand_path() {
    local path="$1"
    # Expand ~ and $HOME
    path="${path/#\~/$HOME}"
    eval echo "$path"
}

# =============================================================================
# Installation Functions
# =============================================================================
install_apt() {
    local package="$1"
    local cmd="${2:-$1}"
    if is_installed "$cmd"; then
        log_success "$package already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "apt install $package"
        else
            log_info "Installing $package..."
            sudo apt install -y "$package"
        fi
    fi
}

install_snap() {
    local package="$1"
    local options="${2:-}"
    local cmd="${3:-$1}"
    if is_installed "$cmd"; then
        log_success "$package already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "snap install $package $options"
        else
            log_info "Installing $package via snap..."
            sudo snap install "$package" $options
        fi
    fi
}

install_flatpak() {
    local app_id="$1"
    local cmd="${2:-}"
    if [ -n "$cmd" ] && is_installed "$cmd"; then
        log_success "$app_id already installed"
    elif flatpak list --app 2>/dev/null | grep -q "$app_id"; then
        log_success "$app_id already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "flatpak install $app_id"
        else
            log_info "Installing $app_id via flatpak..."
            sudo flatpak install -y flathub "$app_id"
        fi
    fi
}

clone_repo() {
    local repo="$1"
    local dest="$2"
    dest=$(expand_path "$dest")
    if [ -d "$dest" ]; then
        log_success "$dest already exists"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "git clone $repo $dest"
        else
            log_info "Cloning $repo..."
            git clone "$repo" "$dest"
        fi
    fi
}

connect_snap() {
    local snap="$1"
    local plug="$2"
    local slot="${3:-}"

    # Check if already connected
    if snap connections "$snap" 2>/dev/null | grep -q "$plug.*$slot"; then
        log_verbose "Snap connection $snap:$plug already exists"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log_dry_run "snap connect $snap:$plug $slot"
    else
        log_info "Connecting $snap:$plug..."
        sudo snap connect "$snap:$plug" $slot || log_warn "Could not connect $snap:$plug"
    fi
}

download_config() {
    local url="$1"
    local dest="$2"
    local cache_control="${3:-false}"
    local executable="${4:-false}"

    dest=$(expand_path "$dest")
    mkdir -p "$(dirname "$dest")"
    backup_file "$dest"

    if [ "$DRY_RUN" -eq 1 ]; then
        log_dry_run "curl $url -> $dest"
    else
        log_verbose "Downloading $(basename "$dest")..."
        if [ "$cache_control" = "true" ]; then
            curl -fsSL -H "Cache-Control: no-cache" -o "$dest" "$url"
        else
            curl -fsSL -o "$dest" "$url"
        fi
        if [ "$executable" = "true" ]; then
            chmod +x "$dest"
        fi
    fi
}

# =============================================================================
# Main Installation
# =============================================================================
main() {
    echo "=== CLI Setup Installation Started at $(date) ===" | tee "$INSTALL_LOG"
    echo "" | tee -a "$INSTALL_LOG"

    log_info "Installation mode: $INSTALL_MODE"
    if [ "$DRY_RUN" -eq 1 ]; then
        log_warn "DRY RUN MODE - No changes will be made"
    fi
    echo ""

    # Run dependency checks
    check_dependencies
    log_system_info
    echo ""

    # Update apt cache
    if [ "$DRY_RUN" -eq 0 ]; then
        log_info "Updating apt package cache..."
        sudo apt update
    fi

    # =========================================================================
    # APT Packages
    # =========================================================================
    echo ""
    log_info "=== Installing APT packages (shell) ==="

    # Shell packages
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
    install_apt gcc
    install_apt make
    install_apt fzf
    install_apt jq
    install_apt duf
    install_apt hyperfine
    install_apt gping
    install_apt git-delta delta

    # Desktop packages (full install only)
    if [ "$INSTALL_MODE" = "full" ]; then
        echo ""
        log_info "=== Installing APT packages (desktop) ==="
        install_apt i3
        install_apt rofi
        install_apt polybar
        install_apt arandr
        install_apt kitty
        install_apt feh
        install_apt imagemagick convert
        install_apt cmatrix
        install_apt picom
        install_apt falkon
        install_apt flatpak
        install_apt xdotool
    fi

    # =========================================================================
    # Flatpak (desktop only)
    # =========================================================================
    if [ "$INSTALL_MODE" = "full" ]; then
        echo ""
        log_info "=== Adding Flatpak repositories ==="
        if [ "$DRY_RUN" -eq 0 ]; then
            # Check if flathub already added
            if flatpak remotes 2>/dev/null | grep -q flathub; then
                log_success "Flathub repository already added"
            else
                log_info "Adding Flathub repository..."
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            fi
        fi

        echo ""
        log_info "=== Installing Flatpak packages ==="
        install_flatpak engineer.atlas.Nyxt
        install_flatpak app.zen_browser.zen
    fi

    # =========================================================================
    # Snap Packages
    # =========================================================================
    echo ""
    log_info "=== Installing Snap packages (shell) ==="
    install_snap httpie "" http
    install_snap kubectl "--classic"
    install_snap helm "--classic"
    install_snap gh
    install_snap doctl
    install_snap k9s "--devmode"
    install_snap glances "--classic"
    install_snap nvim "--classic"
    install_snap bw

    if [ "$INSTALL_MODE" = "full" ]; then
        echo ""
        log_info "=== Installing Snap packages (desktop) ==="
        install_snap bitwarden
    fi

    # =========================================================================
    # Snap Connections
    # =========================================================================
    echo ""
    log_info "=== Configuring Snap connections ==="
    connect_snap doctl ssh-keys ":ssh-keys"
    connect_snap doctl kube-config ""

    if [ "$INSTALL_MODE" = "full" ]; then
        connect_snap bitwarden password-manager-service ""
    fi

    # =========================================================================
    # External Tools
    # =========================================================================
    echo ""
    log_info "=== Installing external tools (shell) ==="

    # Google Cloud SDK
    if is_installed gcloud; then
        log_success "gcloud already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "Install Google Cloud SDK"
        else
            log_info "Installing Google Cloud SDK..."
            curl -fsSL "$GITHUB_RAW_BASE/scripts/install-gcloud.sh" | bash
        fi
    fi

    # mcfly
    if is_installed mcfly; then
        log_success "mcfly already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "Install mcfly"
        else
            log_info "Installing mcfly..."
            curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly
        fi
    fi

    # curlie
    if is_installed curlie; then
        log_success "curlie already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "Install curlie"
        else
            log_info "Installing curlie..."
            curl -sS https://webinstall.dev/curlie | bash
        fi
    fi

    # claude
    if is_installed claude; then
        log_success "claude already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "Install Claude CLI"
        else
            log_info "Installing Claude CLI..."
            curl -fsSL https://claude.ai/install.sh | bash
        fi
    fi

    # xplr
    if is_installed xplr; then
        log_success "xplr already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "Install xplr"
        else
            log_info "Installing xplr..."
            curl -sS "$GITHUB_RAW_BASE/xplr-setup/xplr-setup.sh" | bash
        fi
    fi

    # lazygit
    if is_installed lazygit; then
        log_success "lazygit already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "Install lazygit"
        else
            log_info "Installing lazygit..."
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
            sudo install /tmp/lazygit /usr/local/bin
            rm /tmp/lazygit.tar.gz /tmp/lazygit
        fi
    fi

    # yt-dlp
    if is_installed yt-dlp; then
        log_success "yt-dlp already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "Install yt-dlp"
        else
            log_info "Installing yt-dlp..."
            mkdir -p ~/.local/bin
            curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
            verify_checksum ~/.local/bin/yt-dlp "SKIP"
            chmod a+rx ~/.local/bin/yt-dlp
        fi
    fi

    # posting
    if is_installed posting; then
        log_success "posting already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "Install posting"
        else
            log_info "Installing posting..."
            curl -fsSL "$GITHUB_RAW_BASE/scripts/install-posting.sh" | bash
        fi
    fi

    # oxker
    if is_installed oxker; then
        log_success "oxker already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "Install oxker"
        else
            log_info "Installing oxker..."
            curl -sSL https://raw.githubusercontent.com/mrjackwills/oxker/main/install.sh | bash
        fi
    fi

    # tldr (npm)
    if is_installed tldr; then
        log_success "tldr already installed"
    else
        if [ "$DRY_RUN" -eq 1 ]; then
            log_dry_run "npm install -g tldr"
        else
            log_info "Installing tldr..."
            sudo npm install -g tldr
        fi
    fi

    # Desktop-only external tools
    if [ "$INSTALL_MODE" = "full" ]; then
        echo ""
        log_info "=== Installing external tools (desktop) ==="

        # i3lock-color
        if i3lock --version 2>&1 | grep -q "i3lock-color"; then
            log_success "i3lock-color already installed"
        else
            if [ "$DRY_RUN" -eq 1 ]; then
                log_dry_run "Install i3lock-color"
            else
                log_info "Installing i3lock-color..."
                curl -sSL "$GITHUB_RAW_BASE/i3/install-i3lock-color.sh" | sudo bash
            fi
        fi

        # Cursor IDE
        if is_installed cursor; then
            log_success "Cursor IDE already installed"
        else
            if [ "$DRY_RUN" -eq 1 ]; then
                log_dry_run "Install Cursor IDE"
            else
                log_info "Installing Cursor IDE..."
                curl -fsSL -o /tmp/cursor.deb "https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.1"
                verify_checksum /tmp/cursor.deb "SKIP"
                sudo dpkg -i /tmp/cursor.deb
                sudo apt-get install -f -y
                rm -f /tmp/cursor.deb
            fi
        fi

        # Google Chrome
        if is_installed google-chrome; then
            log_success "Google Chrome already installed"
        else
            if [ "$DRY_RUN" -eq 1 ]; then
                log_dry_run "Install Google Chrome"
            else
                log_info "Installing Google Chrome..."
                curl -fsSL -o /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
                verify_checksum /tmp/google-chrome.deb "SKIP"
                sudo dpkg -i /tmp/google-chrome.deb
                sudo apt-get install -f -y
                rm /tmp/google-chrome.deb
            fi
        fi
    fi

    # =========================================================================
    # Git Repositories
    # =========================================================================
    echo ""
    log_info "=== Cloning git repositories ==="
    clone_repo "https://github.com/agileguy/kickstart.nvim.git" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    clone_repo "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
    clone_repo "https://github.com/magicmonty/bash-git-prompt.git" "$HOME/.bash-git-prompt"

    # =========================================================================
    # Configuration Files
    # =========================================================================
    echo ""
    log_info "=== Fetching configuration files (shell) ==="
    if [ "$SKIP_BACKUP" -eq 0 ]; then
        log_info "Creating backups in: $BACKUP_DIR"
    fi

    # Shell configs
    download_config "$GITHUB_RAW_BASE/.bashrc" "~/.bashrc"
    download_config "$GITHUB_RAW_BASE/tmux.conf" "~/.tmux.conf"

    mkdir -p ~/.config/xplr
    download_config "$GITHUB_RAW_BASE/xplr-setup/init.lua" "~/.config/xplr/init.lua"

    mkdir -p ~/.config/lazygit
    download_config "$GITHUB_RAW_BASE/lazygit/config.yml" "~/.config/lazygit/config.yml"

    mkdir -p ~/.config/delta
    download_config "$GITHUB_RAW_BASE/delta/catppuccin.gitconfig" "~/.config/delta/catppuccin.gitconfig"

    download_config "$GITHUB_RAW_BASE/.gitconfig" "~/.gitconfig"

    mkdir -p ~/.claude
    download_config "$GITHUB_RAW_BASE/claude/CLAUDE.md" "~/.claude/CLAUDE.md" "true"
    download_config "$GITHUB_RAW_BASE/claude/settings.json" "~/.claude/settings.json" "true"

    # Desktop configs (full install only)
    if [ "$INSTALL_MODE" = "full" ]; then
        echo ""
        log_info "=== Fetching configuration files (desktop) ==="

        mkdir -p ~/.config/i3
        download_config "$GITHUB_RAW_BASE/i3/config" "~/.config/i3/config" "true"
        download_config "$GITHUB_RAW_BASE/i3/lock.sh" "~/.config/i3/lock.sh" "false" "true"

        mkdir -p ~/.config/polybar
        download_config "$GITHUB_RAW_BASE/polybar/config.ini" "~/.config/polybar/config.ini"
        download_config "$GITHUB_RAW_BASE/polybar/launch_polybar.sh" "~/.config/polybar/launch_polybar.sh" "false" "true"

        mkdir -p ~/.config/rofi
        download_config "$GITHUB_RAW_BASE/rofi/config.rasi" "~/.config/rofi/config.rasi"
        download_config "$GITHUB_RAW_BASE/rofi/catppuccin-mocha.rasi" "~/.config/rofi/catppuccin-mocha.rasi"

        mkdir -p ~/.config/picom
        download_config "$GITHUB_RAW_BASE/picom/picom.conf" "~/.config/picom/picom.conf"

        mkdir -p ~/.config/nyxt
        download_config "$GITHUB_RAW_BASE/nyxt/config.lisp" "~/.config/nyxt/config.lisp"
        download_config "$GITHUB_RAW_BASE/nyxt/auto-config.3.lisp" "~/.config/nyxt/auto-config.3.lisp"

        mkdir -p ~/.config/kitty
        download_config "$GITHUB_RAW_BASE/kitty/kitty.conf" "~/.config/kitty/kitty.conf" "true"
        download_config "$GITHUB_RAW_BASE/kitty/catppuccin-mocha.conf" "~/.config/kitty/catppuccin-mocha.conf" "true"

        # Background images
        echo ""
        log_info "=== Fetching background images ==="
        mkdir -p ~/.config/backgrounds

        local bg_images=(
            "great_wave.jpg" "great_wave.png" "the_scream.jpg" "starry_night.jpg"
            "sunflowers.jpg" "gauguin_siesta.jpg" "gauguin_tahitian_women.jpg"
            "vangogh_almond_blossom.jpg" "vangogh_bedroom.jpg" "vangogh_cafe_terrace.jpg"
            "vangogh_irises.jpg" "vangogh_wheatfield_crows.jpg" "monet_water_lilies.jpg"
            "monet_impression_sunrise.jpg" "monet_haystacks.jpg" "renoir_boating_party.jpg"
            "renoir_moulin_galette.jpg" "seurat_sunday_afternoon.jpg" "klimt_the_kiss.jpg"
            "turner_temeraire.jpg" "vermeer_girl_pearl.jpg" "botticelli_venus.jpg"
            "manet_olympia.jpg" "degas_absinthe.jpg" "whistler_nocturne.jpg"
        )

        for img in "${bg_images[@]}"; do
            if [ -f ~/.config/backgrounds/"$img" ]; then
                log_verbose "Background $img already exists"
            elif [ "$DRY_RUN" -eq 1 ]; then
                log_dry_run "Download background: $img"
            else
                log_verbose "Downloading $img..."
                curl -fsSL -o ~/.config/backgrounds/"$img" "$GITHUB_RAW_BASE/backgrounds/$img"
            fi
        done

        download_config "$GITHUB_RAW_BASE/backgrounds/rotate_background.sh" "~/.config/backgrounds/rotate_background.sh" "false" "true"

        # Systemd timer for background rotation
        echo ""
        log_info "=== Setting up background rotation timer ==="
        mkdir -p ~/.config/systemd/user
        download_config "$GITHUB_RAW_BASE/systemd/background-rotate.service" "~/.config/systemd/user/background-rotate.service"
        download_config "$GITHUB_RAW_BASE/systemd/background-rotate.timer" "~/.config/systemd/user/background-rotate.timer"

        if [ "$DRY_RUN" -eq 0 ]; then
            systemctl --user daemon-reload
            systemctl --user enable --now background-rotate.timer
        fi
    fi

    # =========================================================================
    # Save Installation State
    # =========================================================================
    if [ "$DRY_RUN" -eq 0 ]; then
        log_info "Saving installation state..."
        cat > "$STATE_FILE" << EOF
{
    "version": "1.0.0",
    "installed_at": "$(date -Iseconds)",
    "mode": "$INSTALL_MODE",
    "backup_dir": "$BACKUP_DIR"
}
EOF
    fi

    # =========================================================================
    # Complete
    # =========================================================================
    echo ""
    log_info "=== Setup complete ==="
    log_success "Installation completed successfully at $(date)"
    log_info "Log file: $INSTALL_LOG"
    if [ "$SKIP_BACKUP" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
        log_info "Backups saved to: $BACKUP_DIR"
    fi
    echo ""

    # Use return if sourced (to avoid closing terminal), exit if executed
    if [ "$SCRIPT_SOURCED" -eq 1 ]; then
        eval "$ORIGINAL_SHELL_OPTS"
        log_info "Script was sourced - shell configuration will be applied automatically"
        echo ""
        return 0
    else
        log_info "To apply the new shell configuration, either:"
        log_info "  1. Open a new terminal window, or"
        log_info "  2. Run: source ~/.bashrc"
        echo ""
        exit 0
    fi
}

# Run main function
main
