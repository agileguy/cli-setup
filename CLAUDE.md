# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal CLI environment setup repository that automates the installation and configuration of a comprehensive development environment on Linux systems. The setup includes terminal tools, editor configuration, shell customization, and i3 window manager configuration with polybar and rofi.

## Repository Structure

- `install.sh` - Main installation script that orchestrates the entire setup (checks if tools are installed before installing)
- `scripts/` - Helper scripts
  - `helpers.sh` - Utility functions for install.sh (is_installed, install_apt, install_snap, install_flatpak, clone_repo)
    - `install_flatpak` runs with sudo for system-wide package installation
  - `install-gcloud.sh` - Installs Google Cloud SDK and GKE plugin from official apt repository
  - `install-posting.sh` - Installs Posting TUI HTTP client via pipx
- `.bashrc` - Custom bash configuration with aliases, prompt customization (Solarized theme), and tool integrations
- `tmux.conf` - tmux configuration with Catppuccin theme and tmux plugin manager (tpm) setup
- `xplr-setup/` - xplr file manager installation and configuration
  - `xplr-setup.sh` - Installation script for xplr
  - `init.lua` - Custom xplr configuration (simplified layout)
- `i3/` - i3 window manager configuration
  - `config` - i3 config with vim-style navigation, rofi integration, polybar, no titlebars, and Catppuccin theme colors
  - `lock.sh` - Lock screen script using i3lock-color with cmatrix screensaver
  - `install-i3lock-color.sh` - Installation script for i3lock-color
- `polybar/` - Polybar status bar configuration
  - `config.ini` - Polybar config with Catppuccin Mocha theme
  - `launch_polybar.sh` - Script to launch polybar (called by i3)
- `rofi/` - Rofi application launcher configuration
  - `config.rasi` - Rofi config with combi mode and icons
  - `catppuccin-mocha.rasi` - Catppuccin Mocha theme for rofi
- `picom/` - Picom compositor configuration
  - `picom.conf` - Picom config with transparency and opacity rules
- `nyxt/` - Nyxt browser configuration
  - `config.lisp` - Custom Catppuccin Mocha theme
  - `auto-config.3.lisp` - Dark mode and default URL settings
- `kitty/` - Kitty terminal configuration
  - `kitty.conf` - Main kitty config with theme, transparency (85%), hidden titlebar, and tab bar styling
  - `catppuccin-mocha.conf` - Catppuccin Mocha color theme
- `lazygit/` - Lazygit configuration
  - `config.yml` - Lazygit config with Catppuccin Mocha theme
- `delta/` - Delta git pager configuration
  - `catppuccin.gitconfig` - Catppuccin themes for delta (all four flavors)
- `.gitconfig` - Git configuration with delta pager setup
- `claude/` - Claude Code CLI configuration
  - `CLAUDE.md` - Global instructions for Claude Code
  - `settings.json` - Permissions and settings for Claude Code
- `backgrounds/` - Desktop wallpaper images and rotation script
  - `rotate_background.sh` - Script to randomly select and set wallpaper
  - Classic and Impressionist artwork collection (see Backgrounds section below)
- `systemd/` - Systemd user services and timers
  - `background-rotate.service` - Oneshot service to rotate background
  - `background-rotate.timer` - Timer to trigger rotation every 5 minutes

## Key Installation Components

The `install.sh` script installs and configures:

**Package Manager Tools:**
- apt packages: cbonsai, btop, ncdu, bat, unzip, ffmpeg, cmus, zoxide, eza, tmux, git, curl, ripgrep, fd-find, nodejs, npm, python3-pip, asciinema, i3, rofi, polybar, arandr, gcc, make, kitty, feh, imagemagick, cmatrix, picom, falkon, flatpak, fzf, jq, duf, hyperfine, gping, git-delta, xdotool
- flatpak packages: nyxt, zen-browser (Flathub repository added automatically)
- snap packages: httpie, kubectl, helm, gh (GitHub CLI), doctl (DigitalOcean CLI), k9s, glances, nvim, bitwarden, bw (Bitwarden CLI)
- apt (official Google repo): google-cloud-cli, google-cloud-cli-gke-gcloud-auth-plugin
- npm packages: tldr

**External Tools (via curl/GitHub releases):**
- mcfly - shell history search
- curlie - curl wrapper with httpie-like interface
- Claude Code CLI
- xplr - terminal file manager
- i3lock-color - enhanced i3lock with color support
- lazygit - terminal UI for git (installed from GitHub releases for full filesystem access)
- cursor - Cursor AI IDE
- yt-dlp - video downloader
- Google Chrome - web browser
- Posting - TUI HTTP client (via pipx)

**Configuration Files:**
- Neovim config: Clones kickstart.nvim to `~/.config/nvim`
- Bash prompt: Installs bash-git-prompt to `~/.bash-git-prompt`
- tmux plugins: Installs tmux plugin manager (tpm) to `~/.tmux/plugins/tpm`
- i3 config: Downloads to `~/.config/i3/config` (with Cache-Control header to avoid stale cache)
- Polybar config: Downloads to `~/.config/polybar/` (config.ini, launch_polybar.sh)
- Rofi config: Downloads to `~/.config/rofi/` (config.rasi, catppuccin-mocha.rasi)
- Picom config: Downloads to `~/.config/picom/picom.conf`
- Kitty config: Downloads to `~/.config/kitty/` (with Cache-Control header to avoid stale cache)

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
- `cc` - Shortcut for Claude Code CLI
- `cc-yolo` - Claude Code CLI with --dangerously-skip-permissions flag
- `weather [city]` - Function to check weather via wttr.in (defaults to Edmonton)
- `commit <message>` - Quick git add and commit function (properly quoted to prevent shell injection)

**Environment Variables:**
- `EDITOR=nvim` - Default editor set to Neovim
- `XDG_CURRENT_DESKTOP=GNOME` - Desktop environment setting

**Shell Enhancements:**
- mcfly: AI-powered shell history search (initialized in .bashrc)
- zoxide: Smarter cd command that learns your most-used directories
- fzf: Fuzzy finder for files and more (Catppuccin Mocha theme; key-bindings disabled to let mcfly handle Ctrl+R)
- bash-git-prompt: Git-aware prompt (only shown in git repositories)
- Solarized color scheme for terminal prompt

## tmux Configuration

The tmux setup uses:
- Catppuccin 'latte' theme
- Vi mode for copy mode
- Custom key bindings:
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

The install script fetches configuration files from the GitHub repository (github.com/agileguy/cli-setup):
- `.bashrc`
- `tmux.conf`
- `xplr-setup/xplr-setup.sh`
- `xplr-setup/init.lua` (deployed to `~/.config/xplr/init.lua`)
- `i3/config` (deployed to `~/.config/i3/config`)
- `i3/lock.sh` (deployed to `~/.config/i3/lock.sh`)
- `polybar/config.ini` (deployed to `~/.config/polybar/config.ini`)
- `polybar/launch_polybar.sh` (deployed to `~/.config/polybar/launch_polybar.sh`)
- `rofi/config.rasi` (deployed to `~/.config/rofi/config.rasi`)
- `rofi/catppuccin-mocha.rasi` (deployed to `~/.config/rofi/catppuccin-mocha.rasi`)
- `picom/picom.conf` (deployed to `~/.config/picom/picom.conf`)
- `nyxt/config.lisp` (deployed to `~/.config/nyxt/config.lisp`)
- `nyxt/auto-config.3.lisp` (deployed to `~/.config/nyxt/auto-config.3.lisp`)
- `kitty/kitty.conf` (deployed to `~/.config/kitty/kitty.conf`)
- `kitty/catppuccin-mocha.conf` (deployed to `~/.config/kitty/catppuccin-mocha.conf`)
- `lazygit/config.yml` (deployed to `~/.config/lazygit/config.yml`)
- `delta/catppuccin.gitconfig` (deployed to `~/.config/delta/catppuccin.gitconfig`)
- `.gitconfig` (deployed to `~/.gitconfig`)
- `claude/CLAUDE.md` (deployed to `~/.claude/CLAUDE.md`)
- `claude/settings.json` (deployed to `~/.claude/settings.json`)

Note: The Neovim configuration comes from a separate repository (github.com/agileguy/kickstart.nvim).

## i3 Window Manager Configuration

The i3 config includes:
- No titlebars on windows (`default_border pixel 0`, `default_floating_border pixel 0`)
- Vim-style window navigation (h/j/k/l)
- Rofi as the application launcher (replacing dmenu)
- Polybar as the status bar (i3bar disabled)
- Catppuccin Mocha theme colors
- Screen layout script on startup (dual monitor support)
- Picom compositor for transparency (automatically disabled on RDP connections)

**Key Bindings:**
- `$mod+Return` - Open terminal (kitty)
- `$mod+b` - Open browser (falkon)
- `$mod+d` - Rofi drun launcher
- `$mod+space` - Rofi combi mode
- `$mod+Tab` - Rofi window switcher
- `$mod+h/j/k/l` - Focus left/down/up/right
- `$mod+Shift+h/j/k/l` - Move window left/down/up/right
- `$mod+Escape` - Lock screen with i3lock-color + cmatrix
- `$mod+z` - Clear terminal (sends Ctrl+L)
- `$mod+Shift+r` - Reload i3 config

## Kitty Configuration

Kitty terminal is configured with:
- Catppuccin Mocha color theme
- 85% background opacity (transparency)
- Hidden titlebar (`hide_window_decorations titlebar-only`)
- Powerline-style tab bar at the bottom
- Font size 11.0

## Polybar Configuration

Polybar uses the Catppuccin Mocha color scheme and is launched automatically by i3 via `~/.config/polybar/launch_polybar.sh`.

## Rofi Configuration

Rofi is configured with:
- Combi mode combining run and window modes
- Catppuccin Mocha theme
- Icons enabled (Oranchelo icon theme)
- Alacritty as the terminal

## Picom Configuration

Picom is a compositor for X11 that provides transparency and visual effects. The configuration includes:
- GLX backend for better performance
- 85% opacity for active and inactive windows
- Fading effects enabled
- Focus tracking fixes for proper opacity restoration on i3 restart
- RDP detection: Automatically disabled when connected via RDP (rdp0 display) to prevent performance issues

**Opacity Rules (windows excluded from transparency):**
- i3lock
- Rofi
- Google Chrome (fullscreen only)
- VLC

## CLI Tools

The following modern CLI tools are installed with Catppuccin Mocha themes where applicable:

**Productivity Tools:**
- fzf: Universal fuzzy finder for files, git branches, and more (Catppuccin Mocha themed via FZF_DEFAULT_OPTS in .bashrc; key-bindings not sourced so mcfly owns Ctrl+R)
- lazygit: Terminal UI for git commands (Catppuccin Mocha themed via config.yml)
- tldr: Simplified, example-driven man pages
- jq: JSON processor for parsing and manipulating JSON data
- Posting: TUI HTTP client for API testing

**Git Enhancement:**
- delta: Syntax-highlighting pager for git diffs (Catppuccin Mocha themed via .gitconfig)

**System Information:**
- duf: Modern df replacement with colorful disk usage display
- hyperfine: Command-line benchmarking tool
- gping: Visual ping with graphical latency display

## Lazygit Configuration

Lazygit uses the Catppuccin Mocha theme configured in `~/.config/lazygit/config.yml`. The theme provides:
- Blue active borders
- Red highlighting for unstaged changes
- Consistent Catppuccin color palette

## Delta Configuration

Delta is configured as the default git pager with Catppuccin Mocha theme:
- Syntax-highlighted diffs with line numbers
- Configured via `~/.gitconfig` which includes `~/.config/delta/catppuccin.gitconfig`
- Supports all four Catppuccin flavors (latte, frappe, macchiato, mocha)

## Backgrounds

The backgrounds collection includes classic and Impressionist/Post-Impressionist masterpieces:
- Van Gogh: Starry Night, Sunflowers, Almond Blossom, Bedroom, Cafe Terrace, Irises, Wheatfield with Crows
- Monet: Water Lilies, Impression Sunrise, Haystacks
- Renoir: Luncheon of the Boating Party, Bal du moulin de la Galette
- Other masters: The Great Wave (Hokusai), The Scream (Munch), Gauguin paintings, Seurat's Sunday Afternoon, Klimt's The Kiss, Turner's Temeraire, Vermeer's Girl with a Pearl Earring, Botticelli's Birth of Venus, Manet's Olympia, Degas' L'Absinthe, Whistler's Nocturne

Backgrounds rotate every 5 minutes via systemd timer.
