# cli-setup

Personal CLI environment setup for Linux systems. Automates installation and configuration of terminal tools, editor, shell customization, and i3 window manager with Catppuccin Mocha theme.

## Quick Start

```bash
# Full installation
curl -sSL https://raw.githubusercontent.com/agileguy/cli-setup/main/install.sh | bash

# Shell-only (no desktop/GUI components)
curl -sSL https://raw.githubusercontent.com/agileguy/cli-setup/main/install.sh | bash -s -- --shell-only
```

Or clone for more options:
```bash
git clone https://github.com/agileguy/cli-setup.git && cd cli-setup

./install.sh                  # Full installation
./install.sh --shell-only     # Shell tools only
./install.sh --dry-run        # Preview without installing
./install.sh --verbose        # Detailed output
./install.sh --force          # Force reinstall
./install.sh --local .        # Offline mode (use local files)
. install.sh --shell-only     # Source for auto shell config
```

The script checks if tools are already installed before installing them.

## Rollback

Restore configuration files from a previous backup:

```bash
./rollback.sh                           # Restore from latest backup
./rollback.sh --list                    # List available backups
./rollback.sh --backup 20241206-143022  # Restore specific backup
./rollback.sh --dry-run                 # Preview restoration
```

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
- Rotating desktop wallpapers (classic artwork, 5-minute rotation, skips existing images)
- Claude Code CLI (global instructions and permissions)
- All installation scripts use strict error handling with trap cleanup and logging
- Automatic timestamped backups of existing configs before overwriting

## Security & Hardening

This repository follows security best practices including:
- Strict error handling (`set -euo pipefail`)
- Automatic timestamped backups before overwriting configs
- Checksum verification for external downloads
- Comprehensive installation logging with color-coded output
- Trap handlers for cleanup on error
- Input sanitization to prevent shell injection
- Shell options preserved when sourced (prevents terminal from closing)
- Dependency checking (apt, sudo, disk space, internet)
- Installation state tracking (`~/.config/cli-setup/state.json`)
- Version tracking with automatic skip if already at latest version
- Path validation (prevents directory traversal and symlink attacks)
- Network retry with exponential backoff
- Offline installation mode (`--local` flag)

See [HARDENING.md](HARDENING.md) for the complete security hardening plan and implementation status (Phases 1-5: Complete ✅).

## Repository Structure

```
.
├── install.sh              # Main installation script (--shell-only, --dry-run, --verbose, --force)
├── rollback.sh             # Restore configs from backup (--list, --backup, --dry-run)
├── manifest.json           # Declarative package/config definitions
├── VERSION                 # Current version (semantic versioning)
├── CHANGELOG.md            # Version history and changes
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

## Troubleshooting

### Installation Issues

**"Command not found: apt"**
This script requires a Debian/Ubuntu-based system. For other distributions, install packages manually.

**"sudo: command not found" or permission denied**
Run the script with a user that has sudo privileges, or install packages as root.

**Snap packages fail to install**
```bash
# Ensure snapd is installed and running
sudo apt install snapd
sudo systemctl enable --now snapd.socket
# May need a reboot or re-login
```

**Flatpak apps don't appear in launcher**
```bash
# Restart your session or run:
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

### Post-Installation Issues

**Shell configuration not loaded**
Open a new terminal or run:
```bash
source ~/.bashrc
```

**mcfly/zoxide not working**
These require the shell to be reloaded. Start a new terminal session.

**Picom (transparency) not working**
- Picom requires X11 (not Wayland)
- Picom is auto-disabled on RDP connections
- Check if picom is running: `pgrep picom`
- Start manually: `picom --config ~/.config/picom/picom.conf &`

**Background rotation not working**
```bash
# Check timer status
systemctl --user status background-rotate.timer

# Restart the timer
systemctl --user restart background-rotate.timer

# Manual rotation
~/.config/backgrounds/rotate_background.sh
```

**i3 keybindings not working**
```bash
# Reload i3 config
$mod+Shift+r

# Or restart i3
i3-msg restart
```

### Recovery

**Restore previous configuration**
```bash
# List available backups
./rollback.sh --list

# Restore from specific backup
./rollback.sh --backup 20241206-143022

# Preview what would be restored
./rollback.sh --dry-run
```

**Clean reinstall**
```bash
./install.sh --force --skip-backup
```

## FAQ

**Q: Can I install only shell tools without the desktop environment?**
A: Yes, use `--shell-only`:
```bash
./install.sh --shell-only
```

**Q: How do I check if my system is compatible before installing?**
A: Run the pre-flight check:
```bash
./install.sh --check
```

**Q: How do I preview what will be installed?**
A: Use dry-run mode:
```bash
./install.sh --dry-run
```

**Q: Can I install on an air-gapped system without internet?**
A: Yes, clone the repo first on a connected machine, then use offline mode:
```bash
# On connected machine
git clone https://github.com/agileguy/cli-setup.git
# Transfer to air-gapped machine, then:
./install.sh --local .
```

**Q: My terminal closes when I source the install script**
A: This was fixed in v2.0.0. Make sure you're using the latest version. The script now preserves shell options.

**Q: How do I update to the latest version?**
A: Pull the latest changes and run the installer:
```bash
git pull
./install.sh
```
If you're already at the latest version, use `--force` to reinstall.

**Q: What gets backed up during installation?**
A: All existing config files are backed up to `~/.config/cli-setup/backups/TIMESTAMP/`. View with:
```bash
ls ~/.config/cli-setup/backups/
```

**Q: How do I change the wallpaper rotation interval?**
A: Edit the systemd timer:
```bash
nano ~/.config/systemd/user/background-rotate.timer
# Change OnUnitActiveSec=5min to desired interval
systemctl --user daemon-reload
systemctl --user restart background-rotate.timer
```

**Q: Some keybindings conflict with my existing setup**
A: Edit the i3 config at `~/.config/i3/config`. The mod key is set to Super (Windows key) by default.

## Prerequisites

- Ubuntu/Debian-based Linux distribution
- sudo access
- At least 2GB free disk space (5GB for full installation)
- Internet connection (unless using `--local` mode)
- X11 display server (for desktop components)
