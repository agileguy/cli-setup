# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-12-06

### Added
- **Modular installation**: `--shell-only` flag for shell-only installs (no desktop components)
- **Dry-run mode**: `--dry-run` flag to preview installation without changes
- **Verbose mode**: `--verbose` / `-v` flag for detailed output
- **Skip backup option**: `--skip-backup` flag for clean installs
- **Force reinstall**: `--force` flag to reinstall even if same version
- **Dependency checking**: Validates apt, sudo, disk space (2GB), internet connectivity
- **Color-coded logging**: INFO (blue), OK (green), WARN (yellow), ERROR (red)
- **Installation state tracking**: Saved to `~/.config/cli-setup/state.json`
- **Version tracking**: VERSION file and installed version in `~/.config/cli-setup/version`
- **Manifest file**: `manifest.json` with declarative package/config definitions
- **Idempotent background downloads**: Skip images that already exist
- **Flathub repository check**: Avoid duplicate repository additions
- **Snap connection verification**: Check before attempting connections

### Changed
- Refactored install.sh from 470 lines to modular architecture
- Improved error messages with line numbers and color coding
- Enhanced help text with usage examples

### Security
- Phase 1 hardening complete (shell injection, error handling, backups, checksums)
- Phase 2 hardening complete (code quality, idempotency, dependency checks, logging)

## [1.0.0] - 2024-12-01

### Added
- Initial release
- APT, Snap, Flatpak package installation
- Configuration file deployment
- i3, polybar, rofi, picom setup
- Catppuccin Mocha theme throughout
- Background wallpaper rotation
- Automatic config backups
- Checksum verification for downloads
- Comprehensive logging
