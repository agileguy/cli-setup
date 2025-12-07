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
INSTALLED_VERSION_FILE="$HOME/.config/cli-setup/version"
BACKUP_DIR="$HOME/.config/cli-setup/backups/$(date +%Y%m%d-%H%M%S)"
MANIFEST_URL="https://raw.githubusercontent.com/agileguy/cli-setup/main/manifest.json"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/agileguy/cli-setup/main"
REPO_VERSION_URL="https://raw.githubusercontent.com/agileguy/cli-setup/main/VERSION"

# Default options
INSTALL_MODE="full"  # full or shell
VERBOSE=0
DRY_RUN=0
SKIP_BACKUP=0
FORCE_INSTALL=0
USE_LOCAL=0
LOCAL_DIR=""
CHECK_ONLY=0
INTERACTIVE=0

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
  --force         Force reinstall even if already at latest version
  --local DIR     Use local files from DIR instead of downloading
  --check         Run pre-flight checks only (no installation)
  --interactive   Interactive mode with prompts and confirmations
  --help, -h      Show this help message

Examples:
  ./install.sh                  # Full installation
  ./install.sh --shell-only     # Shell tools only
  ./install.sh --dry-run        # Preview what would be installed
  ./install.sh --force          # Force reinstall
  ./install.sh --local .        # Use local repo files (offline mode)
  ./install.sh --check          # Validate system before installing
  ./install.sh --interactive    # Guided installation with prompts
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
        --force)
            FORCE_INSTALL=1
            shift
            ;;
        --check)
            CHECK_ONLY=1
            VERBOSE=1  # Enable verbose output for check mode
            shift
            ;;
        --interactive|-i)
            INTERACTIVE=1
            shift
            ;;
        --local)
            USE_LOCAL=1
            LOCAL_DIR="$2"
            if [ -z "$LOCAL_DIR" ] || [ ! -d "$LOCAL_DIR" ]; then
                echo "Error: --local requires a valid directory"
                exit 1
            fi
            # Convert to absolute path
            LOCAL_DIR=$(cd "$LOCAL_DIR" && pwd)
            shift 2
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
# Pre-flight System Check (--check mode)
# =============================================================================
check_system() {
    local warnings=0
    local errors=0

    echo ""
    log_info "=== Pre-flight System Check ==="
    echo ""

    # OS Detection
    log_info "Operating System:"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        log_verbose "  Distribution: $NAME $VERSION"
        if [[ "$ID" != "ubuntu" && "$ID" != "debian" && "$ID_LIKE" != *"debian"* ]]; then
            log_warn "  Non-Debian/Ubuntu system detected - some packages may not install"
            warnings=$((warnings + 1))
        else
            log_success "  Debian/Ubuntu-based system detected"
        fi
    else
        log_warn "  Could not detect OS distribution"
        warnings=$((warnings + 1))
    fi

    # Architecture
    local arch=$(uname -m)
    log_verbose "  Architecture: $arch"
    if [[ "$arch" != "x86_64" ]]; then
        log_warn "  Non-x86_64 architecture - some binaries may not be available"
        warnings=$((warnings + 1))
    fi

    # Display server (for desktop install)
    echo ""
    log_info "Display Environment:"
    if [ "$INSTALL_MODE" = "full" ]; then
        if [ -n "$DISPLAY" ]; then
            log_success "  X11 display detected: $DISPLAY"
        elif [ -n "$WAYLAND_DISPLAY" ]; then
            log_warn "  Wayland display detected - i3/picom require X11"
            warnings=$((warnings + 1))
        else
            log_warn "  No display server detected - desktop components may not work"
            warnings=$((warnings + 1))
        fi
    else
        log_verbose "  Shell-only mode - display server not required"
    fi

    # Package managers
    echo ""
    log_info "Package Managers:"
    if command -v apt &> /dev/null; then
        log_success "  apt: Available"
    else
        log_error "  apt: Not found (required)"
        errors=$((errors + 1))
    fi

    if command -v snap &> /dev/null; then
        log_success "  snap: Available"
    else
        log_warn "  snap: Not found (will be installed via apt)"
        warnings=$((warnings + 1))
    fi

    if command -v flatpak &> /dev/null; then
        log_success "  flatpak: Available"
    else
        if [ "$INSTALL_MODE" = "full" ]; then
            log_verbose "  flatpak: Not found (will be installed)"
        else
            log_verbose "  flatpak: Not found (not needed for shell-only)"
        fi
    fi

    # Disk space
    echo ""
    log_info "Disk Space:"
    local free_space
    free_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    local required_space=2
    if [ "$INSTALL_MODE" = "full" ]; then
        required_space=5
    fi
    if [ "$free_space" -lt "$required_space" ]; then
        log_error "  Available: ${free_space}GB (need ${required_space}GB minimum)"
        errors=$((errors + 1))
    else
        log_success "  Available: ${free_space}GB (${required_space}GB required)"
    fi

    # Network connectivity
    echo ""
    log_info "Network Connectivity:"
    local test_urls=("github.com" "raw.githubusercontent.com" "dl.flathub.org")
    for url in "${test_urls[@]}"; do
        if curl -s --connect-timeout 5 "https://$url" > /dev/null 2>&1; then
            log_success "  $url: Reachable"
        else
            if [ "$USE_LOCAL" -eq 1 ]; then
                log_verbose "  $url: Not reachable (offline mode enabled)"
            else
                log_warn "  $url: Not reachable"
                warnings=$((warnings + 1))
            fi
        fi
    done

    # Sudo access
    echo ""
    log_info "Permissions:"
    if sudo -n true 2>/dev/null; then
        log_success "  sudo: Available (passwordless)"
    elif sudo -v 2>/dev/null; then
        log_success "  sudo: Available (password required)"
    else
        log_error "  sudo: Not available"
        errors=$((errors + 1))
    fi

    # Existing installations
    echo ""
    log_info "Existing Installations:"
    local existing_tools=0
    for tool in nvim tmux git curl zoxide eza fzf lazygit; do
        if command -v "$tool" &> /dev/null; then
            log_verbose "  $tool: Already installed"
            existing_tools=$((existing_tools + 1))
        fi
    done
    if [ "$existing_tools" -gt 0 ]; then
        log_verbose "  $existing_tools tools already installed (will be skipped)"
    fi

    # Check for conflicting packages
    echo ""
    log_info "Potential Conflicts:"
    if command -v nvim &> /dev/null; then
        local nvim_path=$(which nvim)
        if [[ "$nvim_path" == *"snap"* ]]; then
            log_verbose "  nvim: Installed via snap (expected)"
        elif [[ "$nvim_path" == "/opt/"* ]]; then
            log_verbose "  nvim: Installed from source/tarball"
        else
            log_verbose "  nvim: Custom installation at $nvim_path"
        fi
    fi

    # Version check
    echo ""
    log_info "Version:"
    local installed_version=""
    if [ -f "$INSTALLED_VERSION_FILE" ]; then
        installed_version=$(cat "$INSTALLED_VERSION_FILE" | tr -d '[:space:]')
        log_verbose "  Installed version: $installed_version"
    else
        log_verbose "  No previous installation detected"
    fi

    # Summary
    echo ""
    log_info "=== Check Summary ==="
    if [ "$errors" -gt 0 ]; then
        log_error "$errors error(s) found - installation may fail"
    fi
    if [ "$warnings" -gt 0 ]; then
        log_warn "$warnings warning(s) found - review before proceeding"
    fi
    if [ "$errors" -eq 0 ] && [ "$warnings" -eq 0 ]; then
        log_success "System ready for installation"
    elif [ "$errors" -eq 0 ]; then
        log_success "System can proceed with installation (with warnings)"
    fi
    echo ""

    return "$errors"
}

# =============================================================================
# Interactive Mode Functions
# =============================================================================
prompt_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local response

    if [ "$default" = "y" ]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi

    read -r -p "$prompt" response
    response=${response:-$default}

    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

prompt_choice() {
    local prompt="$1"
    shift
    local options=("$@")
    local choice

    echo "$prompt"
    for i in "${!options[@]}"; do
        echo "  $((i+1))) ${options[$i]}"
    done

    while true; do
        read -r -p "Enter choice [1-${#options[@]}]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            return $((choice - 1))
        fi
        echo "Invalid choice. Please enter a number between 1 and ${#options[@]}."
    done
}

run_interactive_setup() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${GREEN}CLI Setup - Interactive Installation${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Installation mode
    echo -e "${YELLOW}Step 1: Installation Mode${NC}"
    prompt_choice "What would you like to install?" "Full installation (shell + desktop/i3)" "Shell tools only (no GUI components)"
    local mode_choice=$?
    if [ "$mode_choice" -eq 1 ]; then
        INSTALL_MODE="shell"
        log_info "Selected: Shell-only installation"
    else
        INSTALL_MODE="full"
        log_info "Selected: Full installation"
    fi
    echo ""

    # Backup preference
    echo -e "${YELLOW}Step 2: Backup Options${NC}"
    if prompt_yes_no "Create backups of existing config files?" "y"; then
        SKIP_BACKUP=0
        log_info "Backups will be created"
    else
        SKIP_BACKUP=1
        log_info "Skipping backups"
    fi
    echo ""

    # Verbose mode
    echo -e "${YELLOW}Step 3: Output Verbosity${NC}"
    if prompt_yes_no "Enable verbose output?" "n"; then
        VERBOSE=1
        log_info "Verbose mode enabled"
    fi
    echo ""

    # Run pre-flight check
    echo -e "${YELLOW}Step 4: System Check${NC}"
    echo "Running pre-flight system check..."
    echo ""
    check_system
    local check_result=$?
    echo ""

    if [ "$check_result" -gt 0 ]; then
        echo -e "${RED}System check found errors.${NC}"
        if ! prompt_yes_no "Continue anyway?" "n"; then
            log_info "Installation cancelled by user"
            if [ "$SCRIPT_SOURCED" -eq 1 ]; then
                eval "$ORIGINAL_SHELL_OPTS"
                return 1
            else
                exit 1
            fi
        fi
    fi

    # Final confirmation
    echo -e "${YELLOW}Step 5: Confirmation${NC}"
    echo ""
    echo "Installation Summary:"
    echo "  - Mode: $INSTALL_MODE"
    echo "  - Backups: $([ "$SKIP_BACKUP" -eq 0 ] && echo "enabled" || echo "disabled")"
    echo "  - Verbose: $([ "$VERBOSE" -eq 1 ] && echo "enabled" || echo "disabled")"
    echo ""

    if ! prompt_yes_no "Proceed with installation?" "y"; then
        log_info "Installation cancelled by user"
        if [ "$SCRIPT_SOURCED" -eq 1 ]; then
            eval "$ORIGINAL_SHELL_OPTS"
            return 0
        else
            exit 0
        fi
    fi

    echo ""
    log_info "Starting installation..."
    echo ""
}

show_installation_summary() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}              ${GREEN}Installation Complete!${NC}                         ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${GREEN}What was installed:${NC}"
    echo "  - Shell tools: git, tmux, nvim, fzf, lazygit, etc."
    echo "  - Shell enhancements: mcfly, zoxide, eza, bat"
    echo "  - Configuration: bashrc, tmux.conf, gitconfig, etc."

    if [ "$INSTALL_MODE" = "full" ]; then
        echo "  - Desktop: i3, polybar, rofi, picom, kitty"
        echo "  - Browsers: Nyxt, Zen Browser, Google Chrome"
        echo "  - Backgrounds: Classic artwork with 5-min rotation"
    fi

    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Open a new terminal or run: source ~/.bashrc"
    if [ "$INSTALL_MODE" = "full" ]; then
        echo "  2. Log out and select i3 as your session"
        echo "  3. Press \$mod+d to open the application launcher"
    fi
    echo ""

    echo -e "${BLUE}Useful commands:${NC}"
    echo "  - cc              : Claude Code CLI"
    echo "  - lazygit         : Terminal UI for git"
    echo "  - btop            : System monitor"
    echo "  - ncdu            : Disk usage analyzer"
    if [ "$INSTALL_MODE" = "full" ]; then
        echo "  - \$mod+Return    : Open terminal"
        echo "  - \$mod+d         : Application launcher"
        echo "  - \$mod+Escape    : Lock screen"
    fi
    echo ""

    if [ "$SKIP_BACKUP" -eq 0 ]; then
        echo -e "${BLUE}Backups saved to:${NC}"
        echo "  $BACKUP_DIR"
        echo ""
    fi

    echo -e "${BLUE}Log file:${NC}"
    echo "  $INSTALL_LOG"
    echo ""
}

# =============================================================================
# Version Checking
# =============================================================================
check_version() {
    log_info "Checking version..."

    # Get version (from local file or remote)
    local remote_version
    if [ "$USE_LOCAL" -eq 1 ]; then
        if [ -f "$LOCAL_DIR/VERSION" ]; then
            remote_version=$(cat "$LOCAL_DIR/VERSION" | tr -d '[:space:]')
        else
            log_warn "Local VERSION file not found, proceeding with installation"
            return 0
        fi
    else
        remote_version=$(curl -fsSL "$REPO_VERSION_URL" 2>/dev/null | tr -d '[:space:]') || {
            log_warn "Could not fetch remote version, proceeding with installation"
            return 0
        }
    fi

    # Get installed version (if exists)
    local installed_version=""
    if [ -f "$INSTALLED_VERSION_FILE" ]; then
        installed_version=$(cat "$INSTALLED_VERSION_FILE" | tr -d '[:space:]')
    fi

    log_verbose "Remote version: $remote_version"
    log_verbose "Installed version: ${installed_version:-none}"

    # If force install, skip version check
    if [ "$FORCE_INSTALL" -eq 1 ]; then
        log_info "Force install requested, proceeding..."
        return 0
    fi

    # Compare versions
    if [ -n "$installed_version" ] && [ "$installed_version" = "$remote_version" ]; then
        log_success "Already at latest version ($remote_version)"
        log_info "Use --force to reinstall"
        if [ "$SCRIPT_SOURCED" -eq 1 ]; then
            eval "$ORIGINAL_SHELL_OPTS"
            return 0
        else
            exit 0
        fi
    fi

    if [ -n "$installed_version" ]; then
        log_info "Upgrading from $installed_version to $remote_version"
    else
        log_info "Installing version $remote_version"
    fi
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

# Validate path is safe (no directory traversal, within allowed directories)
validate_path() {
    local path="$1"
    local expanded_path

    # Expand the path
    expanded_path=$(expand_path "$path")

    # Check for directory traversal attempts
    if [[ "$expanded_path" =~ \.\. ]]; then
        log_error "Path contains directory traversal: $path"
        return 1
    fi

    # Ensure path starts with allowed prefixes
    local allowed_prefixes=("$HOME" "/tmp" "/usr/local")
    local is_allowed=0

    for prefix in "${allowed_prefixes[@]}"; do
        if [[ "$expanded_path" == "$prefix"* ]]; then
            is_allowed=1
            break
        fi
    done

    if [ "$is_allowed" -eq 0 ]; then
        log_error "Path outside allowed directories: $path"
        return 1
    fi

    return 0
}

# Curl with retry and exponential backoff
curl_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local retry_delay=2
    local attempt=1
    local curl_opts="-fsSL --connect-timeout 30 --max-time 300"

    while [ $attempt -le $max_retries ]; do
        log_verbose "Download attempt $attempt/$max_retries: $url"

        if curl $curl_opts -o "$output" "$url"; then
            # Verify we got a non-empty file
            if [ -s "$output" ]; then
                log_verbose "Download successful"
                return 0
            else
                log_warn "Downloaded file is empty"
            fi
        fi

        if [ $attempt -lt $max_retries ]; then
            log_warn "Download failed, retrying in ${retry_delay}s..."
            sleep $retry_delay
            retry_delay=$((retry_delay * 2))  # Exponential backoff
        fi

        attempt=$((attempt + 1))
    done

    log_error "Download failed after $max_retries attempts: $url"
    return 1
}

# Safely create directory (check for symlink attacks)
safe_mkdir() {
    local dir="$1"
    local expanded_dir

    expanded_dir=$(expand_path "$dir")

    # Validate the path first
    if ! validate_path "$dir"; then
        return 1
    fi

    # Check if path exists and is a symlink (potential attack)
    if [ -L "$expanded_dir" ]; then
        log_error "Security: Path is a symlink, refusing to create: $dir"
        return 1
    fi

    # Check parent directory for symlinks
    local parent_dir=$(dirname "$expanded_dir")
    if [ -L "$parent_dir" ] && [ "$parent_dir" != "$HOME" ]; then
        log_error "Security: Parent directory is a symlink: $parent_dir"
        return 1
    fi

    # Create directory
    mkdir -p "$expanded_dir"
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

    # Validate destination path
    if ! validate_path "$dest"; then
        log_error "Refusing to download to unsafe path: $dest"
        return 1
    fi

    safe_mkdir "$(dirname "$dest")"
    backup_file "$dest"

    if [ "$DRY_RUN" -eq 1 ]; then
        if [ "$USE_LOCAL" -eq 1 ]; then
            log_dry_run "copy local file -> $dest"
        else
            log_dry_run "curl $url -> $dest"
        fi
    else
        if [ "$USE_LOCAL" -eq 1 ]; then
            # Extract relative path from URL and copy from local directory
            local rel_path="${url#$GITHUB_RAW_BASE/}"
            local local_file="$LOCAL_DIR/$rel_path"

            if [ -f "$local_file" ]; then
                log_verbose "Copying local file: $rel_path"
                cp "$local_file" "$dest"
            else
                log_error "Local file not found: $local_file"
                return 1
            fi
        else
            log_verbose "Downloading $(basename "$dest")..."
            if ! curl_with_retry "$url" "$dest"; then
                return 1
            fi
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
    if [ "$USE_LOCAL" -eq 1 ]; then
        log_info "Using local files from: $LOCAL_DIR"
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        log_warn "DRY RUN MODE - No changes will be made"
    fi
    echo ""

    # Run pre-flight check if --check mode
    if [ "$CHECK_ONLY" -eq 1 ]; then
        check_system
        local check_result=$?
        if [ "$SCRIPT_SOURCED" -eq 1 ]; then
            eval "$ORIGINAL_SHELL_OPTS"
            return "$check_result"
        else
            exit "$check_result"
        fi
    fi

    # Run interactive setup if --interactive mode
    if [ "$INTERACTIVE" -eq 1 ]; then
        run_interactive_setup
    fi

    # Run dependency and version checks
    check_dependencies
    check_version
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

        # Get and save version
        local installed_version
        installed_version=$(curl -fsSL "$REPO_VERSION_URL" 2>/dev/null | tr -d '[:space:]') || installed_version="unknown"
        echo "$installed_version" > "$INSTALLED_VERSION_FILE"

        cat > "$STATE_FILE" << EOF
{
    "version": "$installed_version",
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

    # Show enhanced summary in interactive mode
    if [ "$INTERACTIVE" -eq 1 ] && [ "$DRY_RUN" -eq 0 ]; then
        show_installation_summary
    else
        log_info "=== Setup complete ==="
        log_success "Installation completed successfully at $(date)"
        log_info "Log file: $INSTALL_LOG"
        if [ "$SKIP_BACKUP" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
            log_info "Backups saved to: $BACKUP_DIR"
        fi
        echo ""
    fi

    # Use return if sourced (to avoid closing terminal), exit if executed
    if [ "$SCRIPT_SOURCED" -eq 1 ]; then
        eval "$ORIGINAL_SHELL_OPTS"
        if [ "$INTERACTIVE" -eq 0 ]; then
            log_info "Script was sourced - shell configuration will be applied automatically"
            echo ""
        fi
        return 0
    else
        if [ "$INTERACTIVE" -eq 0 ]; then
            log_info "To apply the new shell configuration, either:"
            log_info "  1. Open a new terminal window, or"
            log_info "  2. Run: source ~/.bashrc"
            echo ""
        fi
        exit 0
    fi
}

# Run main function
main
