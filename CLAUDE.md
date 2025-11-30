# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal CLI environment setup repository that automates the installation and configuration of a comprehensive development environment on Linux systems. The setup includes terminal tools, editor configuration, and shell customization.

## Repository Structure

- `install.sh` - Main installation script that orchestrates the entire setup (checks if tools are installed before installing)
- `scripts/` - Helper scripts
  - `helpers.sh` - Utility functions for install.sh (is_installed, install_apt, install_snap, clone_repo)
- `.bashrc` - Custom bash configuration with aliases, prompt customization (Solarized theme), and tool integrations
- `tmux.conf` - tmux configuration with vim keybindings, Catppuccin theme, and tmux plugin manager (tpm) setup
- `xplr-setup/` - xplr file manager installation and configuration
  - `xplr-setup.sh` - Installation script for xplr
  - `init.lua` - Custom xplr configuration (simplified layout)

## Key Installation Components

The `install.sh` script installs and configures:

**Package Manager Tools:**
- apt packages: cbonsai, btop, ncdu, bat, unzip, ffmpeg, cmus, zoxide, eza, tmux, git, curl, ripgrep, fd-find, nodejs, npm, asciinema
- snap packages: httpie, kubectl, helm, gh (GitHub CLI), doctl (DigitalOcean CLI), google-cloud-cli, k9s, glances, nvim

**External Tools (via curl):**
- mcfly - shell history search
- curlie - curl wrapper with httpie-like interface
- Claude Code CLI
- xplr - terminal file manager
- cursor-agent - Cursor AI CLI
- cursor - Cursor AI IDE (via getcursor.sh)

**Configuration Files:**
- Neovim config: Clones kickstart.nvim to `~/.config/nvim`
- Bash prompt: Installs bash-git-prompt to `~/.bash-git-prompt`
- tmux plugins: Installs tmux plugin manager (tpm) to `~/.tmux/plugins/tpm`

## Running the Setup

To run the complete setup:
```bash
./install.sh
```

This script requires sudo privileges and will install system packages, snap packages, and configure the shell environment.

## Shell Environment Details

**Key Aliases (from .bashrc):**
- `ls`, `ll`, `la` - Replaced with eza for enhanced directory listings
- `cat` - Replaced with batcat for syntax-highlighted file viewing
- `weather [city]` - Function to check weather via wttr.in (defaults to Edmonton)

**Environment Variables:**
- `EDITOR=nvim` - Default editor set to Neovim
- `XDG_CURRENT_DESKTOP=GNOME` - Desktop environment setting

**Shell Enhancements:**
- mcfly: AI-powered shell history search (initialized in .bashrc)
- zoxide: Smarter cd command that learns your most-used directories
- bash-git-prompt: Git-aware prompt (only shown in git repositories)
- Solarized color scheme for terminal prompt

## tmux Configuration

The tmux setup uses:
- Catppuccin 'latte' theme
- Vim-style pane navigation (h/j/k/l)
- Vi mode for copy mode
- Custom key bindings:
  - Alt+arrow keys for pane switching
  - Shift+arrow keys for window switching
  - Split windows preserve current directory

**tmux Plugins:**
- tpm - Plugin manager
- tmux-sensible - Sensible default settings
- vim-tmux-navigator - Seamless navigation between vim and tmux
- catppuccin/tmux - Theme
- tmux-yank - Enhanced copy/paste

## xplr Configuration

The xplr file manager uses a simplified layout configuration that shows only the file table with margins (defined in `xplr-setup/init.lua`).

## Remote Configuration

The install script fetches some configuration files from the GitHub repository (github.com/agileguy/cli-setup):
- `.bashrc`
- `tmux.conf`
- `xplr-setup/xplr-setup.sh`
- `xplr-setup/init.lua` (deployed to `~/.config/xplr/init.lua`)

Note: The Neovim configuration comes from a separate repository (github.com/agileguy/kickstart.nvim).
