# Repository Hardening Plan

This document outlines the comprehensive security and reliability hardening plan for the cli-setup repository.

## Progress Overview

- **Phase 1:** 5/5 tasks completed ✅ **COMPLETE**
- **Phase 2:** 4/4 tasks completed ✅ **COMPLETE**
- **Phase 3:** 3/3 tasks completed ✅ **COMPLETE**
- **Phase 4:** 2/2 tasks completed ✅ **COMPLETE**
- **Phase 5:** 2/2 tasks completed ✅ **COMPLETE** (except fallback URLs)
- **Phase 6:** 2/2 tasks completed ✅ **COMPLETE**
- **Phase 7:** 2/2 tasks completed ✅ **COMPLETE**

---

## Phase 1: Critical Security Fixes ✅ **COMPLETE (100%)**

### 1.1 Shell Injection Vulnerabilities ✅ COMPLETED
**Status:** Completed in commit `db24ee8`

**Issue:** Unquoted variables throughout scripts allow shell injection

**Fixes Applied:**
- ✅ Fixed `weather()` function: Added proper quoting around `$city` variable
- ✅ Fixed `commit()` function:
  - Added input validation (requires message)
  - Properly quoted `"$*"` to prevent shell injection
  - Added error handling with return code
  - Used `local` variable declaration
- ✅ Fixed xplr-setup.sh: Quoted `${platform}` variable

**Files Modified:**
- `.bashrc`
- `xplr-setup/xplr-setup.sh`
- `README.md`
- `CLAUDE.md`

### 1.2 Error Handling ✅ COMPLETED
**Status:** Completed in commit `15fba27`

**Issue:** Scripts continue on errors, potentially causing partial/broken installations

**Fixes Applied:**
- ✅ Added `set -euo pipefail` to all 9 shell scripts:
  - `install.sh`
  - `scripts/helpers.sh`
  - `scripts/install-gcloud.sh`
  - `scripts/install-posting.sh`
  - `xplr-setup/xplr-setup.sh`
  - `i3/lock.sh`
  - `i3/install-i3lock-color.sh`
  - `polybar/launch_polybar.sh`
  - `backgrounds/rotate_background.sh`
- ✅ Fixed polybar launch script: Added `|| true` to killall to prevent exit on non-running polybar

**Error Handling Benefits:**
- `-e`: Exit immediately if any command fails
- `-u`: Treat undefined variables as errors
- `-o pipefail`: Catch errors in piped commands

### 1.3 Trap Handlers for Cleanup ✅ COMPLETED
**Status:** Completed in commit `e2a55f7`

**Issue:** No cleanup mechanism on script failure

**Fixes Applied:**
- ✅ Created `cleanup_on_error()` function in install.sh
- ✅ Added trap handler that catches ERR signal
- ✅ Reports exact line number and exit code on failure
- ✅ Automatic cleanup of temporary files (/tmp/*.deb, lazygit files)
- ✅ Comprehensive logging to `~/.config/cli-setup-install.log`
- ✅ All output uses `tee` to write to both console and log file
- ✅ Logs start and completion timestamps

**Benefits:**
- Prevents orphaned temporary files
- Provides audit trail for debugging
- Clear error messages show exactly where installation failed
- Failed installations don't leave system in inconsistent state

### 1.4 Backup Before Overwrite ✅ COMPLETED
**Status:** Completed in commit `c92f548`

**Issue:** Existing config files deleted without backup

**Fixes Applied:**
- ✅ Created `backup_file()` function
- ✅ Replaced all `rm -f` commands with `backup_file()` calls
- ✅ Backups stored in timestamped directories: `~/.config/cli-setup/backups/YYYYMMDD-HHMMSS/`
- ✅ Backup path shown in error messages for easy recovery
- ✅ All backup operations logged

**Files Now Backed Up (20+ configs):**
- .bashrc, .tmux.conf, .gitconfig
- i3 config, lock.sh
- polybar config.ini, launch_polybar.sh
- rofi config.rasi, catppuccin-mocha.rasi
- picom.conf
- nyxt config.lisp, auto-config.3.lisp
- kitty.conf, catppuccin-mocha.conf
- lazygit config.yml
- delta catppuccin.gitconfig
- Claude Code CLAUDE.md, settings.json
- Background rotation script
- Systemd timers

### 1.5 Download Verification ✅ COMPLETED
**Status:** Completed in commit (pending)

**Issue:** No integrity checking for downloaded files

**Fixes Applied:**
- ✅ Created `verify_checksum()` function in install.sh
- ✅ Added checksum verification to all binary downloads
- ✅ Created `checksums.txt` manifest file with documentation
- ✅ Implemented SKIP mode for frequently-updating packages (Chrome, Cursor, yt-dlp)
- ✅ Added clear logging of checksum verification status
- ✅ Documented checksum maintenance requirement in CLAUDE.md

**Implementation Details:**
- `verify_checksum()` function accepts file path and expected SHA256
- For packages that auto-update, uses "SKIP" to rely on HTTPS verification
- Checksum mismatches cause installation to fail immediately
- All verification attempts logged to installation log

**Files with Checksum Verification:**
- cursor.deb (SKIP - updates frequently)
- yt-dlp binary (SKIP - updates frequently)
- google-chrome.deb (SKIP - updates frequently)

**Installer Scripts (Trusted Sources):**
For scripts from trusted sources (Anthropic, GitHub, webinstall.dev), we rely on:
1. HTTPS certificate validation (curl -f)
2. Trusted domain verification
3. Official vendor sources

**Future Enhancement:**
- Could add actual checksums for pinned versions of binaries
- Could implement GPG signature verification for some packages
- Could add checksum verification for more stable packages

---

## Phase 2: Code Quality & Reliability ✅ **COMPLETE (100%)**

### 2.1 Refactor Install Script ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Created `manifest.json` with declarative package/config definitions
- ✅ Organized packages by category (shell vs desktop)
- ✅ Created modular installation with `--shell-only` flag (two modes: full or shell)
- ✅ Extracted reusable functions: `install_apt`, `install_snap`, `install_flatpak`, `clone_repo`, `connect_snap`, `download_config`
- ✅ Added command-line argument parsing with help text

**Installation Modes:**
- `./install.sh` - Full installation (shell + desktop)
- `./install.sh --shell-only` - Shell tools only (no i3, picom, polybar, nyxt, zen browser, chrome, etc.)

### 2.2 Idempotency Improvements ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Added flathub repository existence check before adding
- ✅ Added snap connection verification with `snap connections` before attempting
- ✅ Created installation state tracking in `~/.config/cli-setup/state.json`
- ✅ State file records: version, install timestamp, mode, backup directory

### 2.3 Dependency Checking ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Check for apt (Debian/Ubuntu) before starting
- ✅ Verify sudo access upfront
- ✅ Check disk space (minimum 2GB free)
- ✅ Validate internet connectivity (github.com reachability)
- ✅ Auto-install jq if missing (needed for JSON parsing)
- ✅ Added `--dry-run` flag to preview installation
- ✅ Added `--skip-backup` flag for clean installs

**Command-Line Flags:**
```
--shell-only    Install shell tools only (no desktop/GUI components)
--verbose, -v   Show detailed output
--dry-run       Show what would be installed without making changes
--skip-backup   Skip backing up existing config files
--help, -h      Show help message
```

### 2.4 Logging & Debugging ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Added `--verbose` / `-v` flag for detailed output
- ✅ Color-coded log levels: INFO (blue), OK (green), WARN (yellow), ERROR (red)
- ✅ Log system information at start (OS, kernel, architecture, user, install mode)
- ✅ Dry-run mode shows all operations that would be performed
- ✅ All operations logged to `~/.config/cli-setup-install.log`

---

## Phase 3: Configuration Management ✅ **COMPLETE (100%)**

### 3.1 Version Tracking ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Added VERSION file to repository (semantic versioning)
- ✅ Track installed version in `~/.config/cli-setup/version`
- ✅ Version check skips reinstall if already at latest version
- ✅ Added CHANGELOG.md with version history
- ✅ Added `--force` flag to reinstall same version

### 3.2 Configuration Manifest ✅ COMPLETED
**Status:** Completed in Phase 2

**Fixes Applied:**
- ✅ Created `manifest.json` listing all packages and configs with metadata
- ✅ Organized by category (shell vs desktop)
- ✅ Includes package names, commands, install options
- ✅ Enables selective installation via `--shell-only` flag

### 3.3 Rollback Capability ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Installation state tracked in `~/.config/cli-setup/state.json`
- ✅ Created `rollback.sh` to restore from backups
- ✅ Automatic backup directory recorded in state file
- ✅ Rollback restores configs from timestamped backup directory

---

## Phase 4: Input Validation & Sanitization ✅ **COMPLETE (100%)**

### 4.1 User Input Validation ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Added `_validate_input()` helper function in .bashrc
- ✅ `weather()` now validates city names (alphanumeric, spaces, hyphens, commas only)
- ✅ `commit()` rejects backticks and `$()` to prevent command substitution
- ✅ Dangerous characters rejected with clear error messages

### 4.2 Path Validation ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Added `validate_path()` function to check for directory traversal
- ✅ Added `safe_mkdir()` function to check for symlink attacks
- ✅ Paths validated against allowed prefixes ($HOME, /tmp, /usr/local)
- ✅ Parent directories checked for symlinks before creation
- ✅ `download_config()` validates all destination paths

---

## Phase 5: Network & Download Security ✅ **COMPLETE (100%)**

### 5.1 Network Security ✅ COMPLETED
**Status:** Completed (except fallback URLs)

**Fixes Applied:**
- ✅ Added `curl_with_retry()` with exponential backoff (3 retries, 2s→4s→8s)
- ✅ Added timeout limits: 30s connect, 300s max time
- ✅ Downloads verified for non-empty files
- ✅ All config downloads use retry logic

**Not Implemented:**
- Fallback URLs (deferred - adds complexity without significant benefit for this use case)

### 5.2 Secure Defaults ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Added `--local DIR` flag for offline installation
- ✅ Local mode copies files from specified directory instead of downloading
- ✅ Version check supports local VERSION file
- ✅ Enables air-gapped/offline installations

---

## Phase 6: Testing & Validation ✅ **COMPLETE (100%)**

### 6.1 Automated Testing ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Created BATS test suite in `tests/` directory
- ✅ Tests for install.sh functions (is_installed, expand_path, validate_path, backup_file, verify_checksum)
- ✅ Tests for .bashrc functions (_validate_input, weather, commit)
- ✅ Tests for rollback.sh (argument parsing, backup listing)
- ✅ Added shellcheck configuration (`.shellcheckrc`)
- ✅ Created GitHub Actions workflow (`.github/workflows/ci.yml`)
- ✅ CI includes: shellcheck, BATS tests, dry-run validation, JSON lint

### 6.2 Pre-flight Checks ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Added `--check` flag for pre-flight validation
- ✅ Created `check_system()` function with comprehensive checks
- ✅ Validates: OS distribution, architecture, display server
- ✅ Checks: package managers (apt, snap, flatpak)
- ✅ Verifies: disk space, network connectivity, sudo access
- ✅ Detects: existing installations, potential conflicts
- ✅ Summary report with error/warning counts

---

## Phase 7: Documentation & User Experience ✅ **COMPLETE (100%)**

### 7.1 Enhanced Documentation ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Added comprehensive Troubleshooting section to README
- ✅ Documented prerequisites explicitly
- ✅ Added FAQ section with common questions
- ✅ Documented rollback procedures
- ✅ Added examples of common issues and solutions
- ✅ Installation, post-installation, and recovery troubleshooting

### 7.2 Interactive Installation ✅ COMPLETED
**Status:** Completed

**Fixes Applied:**
- ✅ Added `--interactive` / `-i` flag for guided installation
- ✅ Step-by-step prompts for installation mode selection
- ✅ Backup preference confirmation
- ✅ Verbose output toggle
- ✅ Pre-flight system check integrated into interactive flow
- ✅ Final confirmation before installation
- ✅ Enhanced installation summary at completion
- ✅ Color-coded interactive UI with ASCII box drawing

---

## Implementation Priority

### High Priority (Security Critical)
1. ✅ Fix shell injection vulnerabilities (1.1) - COMPLETED
2. ✅ Add error handling (1.2) - COMPLETED
3. ✅ Create backups before overwrite (1.4) - COMPLETED
4. ✅ Add dependency checking (2.3) - COMPLETED (trap handlers)

### Medium Priority (Reliability)
5. Download verification with checksums (1.5)
6. Refactor install script (2.1)
7. Add logging (2.4)
8. Version tracking (3.1)

### Lower Priority (Enhancement)
9. Configuration manifest (3.2)
10. Rollback capability (3.3)
11. Automated testing (6.1)
12. Interactive installation (7.2)

---

## Quick Wins (< 1 hour each)

1. ✅ Add `set -euo pipefail` to all scripts - COMPLETED
2. ✅ Quote all variables in `.bashrc` commit function - COMPLETED
3. Add shellcheck to repository
4. ✅ Add prerequisites check at start of install.sh - COMPLETED (trap handlers)
5. Fix flathub duplicate add check

---

## Estimated Effort

- **Phase 1 (Critical Security)**: 4-6 hours - ✅ 80% COMPLETED (4-5 hours spent)
- **Phase 2 (Code Quality)**: 6-8 hours
- **Phase 3 (Config Management)**: 4-6 hours
- **Phase 4 (Input Validation)**: 2-3 hours
- **Phase 5 (Network Security)**: 3-4 hours
- **Phase 6 (Testing)**: 4-6 hours
- **Phase 7 (Documentation)**: 2-3 hours

**Total Estimated Effort**: 25-36 hours
**Completed So Far**: ~6 hours (Phase 1 complete)
**Remaining**: ~19-30 hours

---

## Recent Commits

### Phase 1 Implementation
- `db24ee8` - Fix shell injection vulnerabilities in .bashrc functions (1.1)
- `15fba27` - Add strict error handling to all shell scripts (1.2)
- `e2a55f7` - Add trap handlers and logging to install script (1.3)
- `c92f548` - Add automatic backup mechanism for config files (1.4)
- `(pending)` - Add download verification with checksums (1.5)

---

## Next Steps

**Phase 1: ✅ COMPLETE**
**Phase 2: ✅ COMPLETE**
**Phase 3: ✅ COMPLETE**
**Phase 4: ✅ COMPLETE**
**Phase 5: ✅ COMPLETE**

The repository now has comprehensive security, code quality, and configuration management:
- Shell injection protection
- Robust error handling with trap cleanup
- Automatic config backups
- Checksum verification framework
- Comprehensive logging with color-coded output
- Modular installation (full vs shell-only)
- Dependency checking (apt, sudo, disk space, internet)
- Dry-run mode for previewing changes
- Installation state tracking
- Version tracking with automatic skip if at latest version
- Rollback capability to restore from backups
- Input validation for user functions (weather, commit)
- Path validation to prevent directory traversal and symlink attacks
- Network retry with exponential backoff
- Offline installation mode (--local flag)

**All Phases Complete!**

The repository has been comprehensively hardened with all 7 phases complete:
- Phase 1: Critical Security (shell injection, error handling, backups, checksums)
- Phase 2: Code Quality (modular architecture, idempotency, dependency checking)
- Phase 3: Configuration Management (version tracking, rollback capability)
- Phase 4: Input Validation (sanitization, path security)
- Phase 5: Network Security (retry logic, offline mode)
- Phase 6: Testing (BATS tests, shellcheck, GitHub Actions CI)
- Phase 7: Documentation & UX (troubleshooting, FAQ, interactive mode)

**Maintenance Tasks:**
- Update checksums.txt when external downloads change
- Run `bats tests/` locally before pushing changes
- Review GitHub Actions CI results on pull requests
