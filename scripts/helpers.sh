#!/bin/bash

# Check if a command/tool is installed
# Usage: is_installed <command_name>
# Returns: 0 if installed, 1 if not
is_installed() {
    command -v "$1" &> /dev/null
}

# Install apt package if not already installed
# Usage: install_apt <package_name> [command_name]
# command_name is optional - defaults to package_name
install_apt() {
    local package="$1"
    local cmd="${2:-$1}"
    if is_installed "$cmd"; then
        echo "✓ $package already installed"
    else
        echo "→ Installing $package..."
        sudo apt install -y "$package"
    fi
}

# Install snap package if not already installed
# Usage: install_snap <package_name> [options] [command_name]
# Example: install_snap kubectl "--classic" kubectl
install_snap() {
    local package="$1"
    local options="$2"
    local cmd="${3:-$1}"
    if is_installed "$cmd"; then
        echo "✓ $package already installed"
    else
        echo "→ Installing $package via snap..."
        sudo snap install "$package" $options
    fi
}

# Install flatpak package if not already installed
# Usage: install_flatpak <app_id> [command_name]
# Example: install_flatpak engineer.atlas.Nyxt nyxt
install_flatpak() {
    local app_id="$1"
    local cmd="${2:-}"
    if [ -n "$cmd" ] && is_installed "$cmd"; then
        echo "✓ $app_id already installed"
    elif flatpak list --app | grep -q "$app_id"; then
        echo "✓ $app_id already installed"
    else
        echo "→ Installing $app_id via flatpak..."
        flatpak install -y flathub "$app_id"
    fi
}

# Clone git repo if directory doesn't exist
# Usage: clone_repo <repo_url> <destination>
clone_repo() {
    local repo="$1"
    local dest="$2"
    if [ -d "$dest" ]; then
        echo "✓ $dest already exists"
    else
        echo "→ Cloning $repo to $dest..."
        git clone "$repo" "$dest"
    fi
}
