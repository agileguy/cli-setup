# cli-setup

Personal CLI environment setup for Linux systems. Automates installation and configuration of terminal tools, editor, and shell customization.

## Quick Start

```bash
git clone https://github.com/agileguy/cli-setup.git
cd cli-setup
./install.sh
```

The script checks if tools are already installed before installing them.

## What Gets Installed

**APT Packages:**
cbonsai, btop, ncdu, bat, unzip, ffmpeg, cmus, zoxide, eza, tmux, git, curl, ripgrep, fd-find, nodejs, npm, asciinema

**Snap Packages:**
httpie, kubectl, helm, gh, doctl, google-cloud-cli, k9s, glances, nvim

**CLI Tools (via curl):**
- mcfly - shell history search
- curlie - httpie-like curl wrapper
- claude - Claude Code CLI
- xplr - terminal file manager
- cursor-agent - Cursor AI CLI
- cursor - Cursor AI IDE (via getcursor.sh)

**Configuration:**
- Neovim config (kickstart.nvim)
- tmux config with Catppuccin theme
- bash-git-prompt
- Custom .bashrc with aliases and integrations

## Repository Structure

```
.
├── install.sh           # Main installation script
├── scripts/
│   └── helpers.sh       # Helper functions (is_installed, install_apt, etc.)
├── .bashrc              # Bash configuration
├── tmux.conf            # tmux configuration
└── xplr-setup/
    ├── xplr-setup.sh    # xplr installation script
    └── init.lua         # xplr configuration
```

## Shell Aliases

- `ls`, `ll`, `la` - eza (enhanced ls)
- `cat` - batcat (syntax highlighting)
- `weather [city]` - weather via wttr.in
