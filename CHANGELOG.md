# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.3] - 2024-12-08

### Fixed
- i3lock-color detection now checks for "Cassandra Fox" in version output instead of "i3lock-color" string which doesn't appear

## [2.1.2] - 2024-12-08

### Fixed
- Version check now uses GitHub API instead of raw.githubusercontent.com to avoid CDN caching issues

## [2.1.1] - 2024-12-08

### Changed
- Kitty: Disabled mouse clicks from inserting characters in terminal (mouse_map no_op for left/middle/right clicks)

## [2.1.0] - 2024-12-06

### Added
- **Automated Testing**: BATS test suite for install.sh, .bashrc, and rollback.sh functions
- **GitHub Actions CI**: Automated shellcheck, BATS tests, dry-run validation, and JSON lint
- **Pre-flight validation**: `--check` flag to validate system compatibility before installation
- **Interactive mode**: `--interactive` / `-i` flag for guided installation with prompts
- **Troubleshooting guide**: Comprehensive troubleshooting section in README
- **FAQ section**: Common questions and answers in README
- **Prerequisites section**: Explicit system requirements documentation

### Changed
- Enhanced installation summary in interactive mode with color-coded UI
- Improved system compatibility checking with detailed reports
- Full installation now requires 5GB disk space (up from 2GB)

### Security
- Phase 6 hardening complete (automated testing, CI/CD)
- Phase 7 hardening complete (documentation, interactive mode)
- All 7 phases of security hardening now complete

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
- **Rollback script**: `rollback.sh` to restore configs from backups (--list, --backup, --dry-run)
- **Input validation**: `_validate_input()` helper, validated `weather()` and `commit()` functions
- **Path validation**: `validate_path()` and `safe_mkdir()` to prevent directory traversal and symlink attacks
- **Network retry**: `curl_with_retry()` with exponential backoff (3 attempts, 2s→4s→8s delays)
- **Offline mode**: `--local DIR` flag for air-gapped installations using local files

### Changed
- Refactored install.sh from 470 lines to modular architecture
- Improved error messages with line numbers and color coding
- Enhanced help text with usage examples

### Security
- Phase 1 hardening complete (shell injection, error handling, backups, checksums)
- Phase 2 hardening complete (code quality, idempotency, dependency checks, logging)
- Phase 3 hardening complete (version tracking, rollback capability)
- Phase 4 hardening complete (input validation, path validation)
- Phase 5 hardening complete (network retry, offline mode)

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
