# cli-setup

Personal CLI environment setup for Linux systems. Automates installation and configuration of terminal tools, editor, shell customization, and i3 window manager with Catppuccin Mocha theme.

## Quick Start

```bash
curl -sSL https://raw.githubusercontent.com/agileguy/cli-setup/main/install.sh | bash
```

Or clone and source to automatically apply shell configuration:
```bash
git clone https://github.com/agileguy/cli-setup.git && cd cli-setup && . install.sh
```

The script checks if tools are already installed before installing them.

## What Gets Installed

**APT Packages:**
cbonsai, btop, ncdu, bat, unzip, ffmpeg, cmus, zoxide, eza, tmux, git, curl, ripgrep, fd-find, nodejs, npm, python3-pip, asciinema, i3, rofi, polybar, arandr, gcc, make, kitty, feh, imagemagick, cmatrix, picom, falkon, flatpak, fzf, jq, duf, hyperfine, gping, git-delta, xdotool

**Flatpak Packages:**
nyxt, zen-browser

**Snap Packages:**
httpie, kubectl, helm, gh, doctl, k9s, glances, nvim, bitwarden, bw

**Google Cloud SDK (via apt):**
google-cloud-cli, google-cloud-cli-gke-gcloud-auth-plugin

**CLI Tools (via curl/git):**
- mcfly - shell history search
- curlie - httpie-like curl wrapper
- claude - Claude Code CLI
- xplr - terminal file manager
- lazygit - terminal UI for git
- cursor - Cursor AI IDE
- yt-dlp - video downloader
- Google Chrome - web browser
- i3lock-color - enhanced screen locker
- Posting - TUI HTTP client
- oxker - Docker container TUI

**Configuration:**
- Neovim config (kickstart.nvim)
- tmux config with Catppuccin theme
- i3 window manager (no titlebars, vim-style navigation, Catppuccin Mocha colors)
- kitty terminal (85% transparency, hidden titlebar, Catppuccin Mocha theme)
- picom compositor (85% window opacity, GLX backend, auto-disabled on RDP connections)
- polybar status bar (Catppuccin Mocha theme)
- rofi launcher (Catppuccin Mocha theme)
- lazygit (Catppuccin Mocha theme)
- delta git pager (Catppuccin Mocha theme)
- fzf fuzzy finder (Catppuccin Mocha theme)
- bash-git-prompt
- Custom .bashrc with aliases and integrations (input sanitized)
- Rotating desktop wallpapers (classic artwork, 5-minute rotation)
- Claude Code CLI (global instructions and permissions)
- All installation scripts use strict error handling with trap cleanup and logging
- Automatic timestamped backups of existing configs before overwriting

## Security & Hardening

This repository follows security best practices including:
- Strict error handling (`set -euo pipefail`)
- Automatic timestamped backups before overwriting configs
- Checksum verification for external downloads
- Comprehensive installation logging
- Trap handlers for cleanup on error
- Input sanitization to prevent shell injection
- Shell options preserved when sourced (prevents terminal from closing)

See [HARDENING.md](HARDENING.md) for the complete security hardening plan and implementation status (Phase 1: Complete ✅).

## Repository Structure

```
.
├── install.sh              # Main installation script
├── checksums.txt           # SHA256 checksums for downloads
├── HARDENING.md            # Security hardening plan and status
├── .gitignore              # Excludes backups, logs, and temp files
├── scripts/
│   ├── helpers.sh          # Helper functions (install_flatpak uses sudo)
│   ├── install-gcloud.sh   # Google Cloud SDK installer
│   └── install-posting.sh  # Posting TUI HTTP client installer
├── .bashrc                 # Bash configuration
├── .gitconfig              # Git configuration with delta pager
├── tmux.conf               # tmux configuration
├── i3/
│   ├── config              # i3 window manager configuration
│   ├── lock.sh             # i3lock-color lock script
│   └── install-i3lock-color.sh
├── kitty/
│   ├── kitty.conf          # Kitty terminal configuration
│   └── catppuccin-mocha.conf
├── polybar/
│   ├── config.ini          # Polybar configuration
│   └── launch_polybar.sh
├── rofi/
│   ├── config.rasi         # Rofi launcher configuration
│   └── catppuccin-mocha.rasi
├── picom/
│   └── picom.conf          # Compositor config
├── nyxt/
│   ├── config.lisp         # Nyxt browser configuration
│   └── auto-config.3.lisp
├── lazygit/
│   └── config.yml          # Lazygit configuration
├── delta/
│   └── catppuccin.gitconfig
├── claude/
│   ├── CLAUDE.md           # Global Claude Code instructions
│   └── settings.json       # Claude Code permissions/settings
├── backgrounds/            # Desktop wallpapers (Van Gogh, Monet, etc.)
│   └── rotate_background.sh
├── systemd/
│   ├── background-rotate.service
│   └── background-rotate.timer
└── xplr-setup/
    ├── xplr-setup.sh
    └── init.lua
```

## Key Bindings (i3)

- `$mod+Return` - Open terminal (kitty)
- `$mod+b` - Open browser
- `$mod+d` - Rofi drun launcher
- `$mod+space` - Rofi combi mode
- `$mod+Tab` - Window switcher
- `$mod+h/j/k/l` - Vim-style focus navigation
- `$mod+Escape` - Lock screen
- `$mod+w` - Tabbed layout

## Shell Aliases

- `ls`, `ll`, `la` - eza (enhanced ls)
- `cat` - batcat (syntax highlighting)
- `cc` - Claude Code CLI
- `weather [city]` - weather via wttr.in
- `commit <message>` - quick git add and commit (input sanitized)
