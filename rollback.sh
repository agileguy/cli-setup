#!/bin/bash
set -euo pipefail

# =============================================================================
# Rollback Script - Restore configuration files from backup
# =============================================================================

STATE_FILE="$HOME/.config/cli-setup/state.json"
INSTALL_LOG="$HOME/.config/cli-setup-install.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
Usage: rollback.sh [OPTIONS]

Restore configuration files from a previous backup.

Options:
  --list          List available backups
  --backup DIR    Specify backup directory to restore from
  --latest        Restore from most recent backup (default)
  --dry-run       Show what would be restored without making changes
  --help, -h      Show this help message

Examples:
  ./rollback.sh                           # Restore from latest backup
  ./rollback.sh --list                    # List available backups
  ./rollback.sh --backup 20241206-143022  # Restore specific backup
  ./rollback.sh --dry-run                 # Preview restoration
EOF
}

list_backups() {
    local backup_base="$HOME/.config/cli-setup/backups"

    if [ ! -d "$backup_base" ]; then
        log_error "No backup directory found at $backup_base"
        exit 1
    fi

    log_info "Available backups:"
    echo ""

    local count=0
    for backup in "$backup_base"/*/; do
        if [ -d "$backup" ]; then
            local backup_name=$(basename "$backup")
            local file_count=$(find "$backup" -type f 2>/dev/null | wc -l)
            echo "  $backup_name ($file_count files)"
            count=$((count + 1))
        fi
    done

    if [ "$count" -eq 0 ]; then
        log_warn "No backups found"
    else
        echo ""
        log_info "Total: $count backup(s)"
    fi
}

get_latest_backup() {
    local backup_base="$HOME/.config/cli-setup/backups"

    if [ ! -d "$backup_base" ]; then
        echo ""
        return
    fi

    # Get most recent backup directory
    ls -1t "$backup_base" 2>/dev/null | head -n1
}

restore_backup() {
    local backup_dir="$1"
    local dry_run="$2"
    local backup_base="$HOME/.config/cli-setup/backups"
    local full_backup_path="$backup_base/$backup_dir"

    if [ ! -d "$full_backup_path" ]; then
        log_error "Backup directory not found: $full_backup_path"
        exit 1
    fi

    log_info "Restoring from backup: $backup_dir"
    echo ""

    if [ "$dry_run" -eq 1 ]; then
        log_warn "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    local restored=0
    local failed=0

    # Find all files in backup and restore them
    while IFS= read -r -d '' backup_file; do
        # Remove backup base path to get relative path
        local relative_path="${backup_file#$full_backup_path}"
        local target_path="$relative_path"

        if [ "$dry_run" -eq 1 ]; then
            echo "  Would restore: $target_path"
        else
            # Create target directory if needed
            mkdir -p "$(dirname "$target_path")"

            if cp "$backup_file" "$target_path" 2>/dev/null; then
                log_success "Restored: $target_path"
                restored=$((restored + 1))
            else
                log_error "Failed to restore: $target_path"
                failed=$((failed + 1))
            fi
        fi
    done < <(find "$full_backup_path" -type f -print0)

    echo ""
    if [ "$dry_run" -eq 1 ]; then
        log_info "Dry run complete. Use without --dry-run to apply changes."
    else
        log_info "Restoration complete: $restored restored, $failed failed"

        if [ "$restored" -gt 0 ]; then
            echo ""
            log_info "To apply shell changes, run: source ~/.bashrc"
        fi
    fi
}

# =============================================================================
# Main
# =============================================================================
BACKUP_DIR=""
DRY_RUN=0
LIST_ONLY=0
USE_LATEST=1

while [[ $# -gt 0 ]]; do
    case $1 in
        --list)
            LIST_ONLY=1
            shift
            ;;
        --backup)
            BACKUP_DIR="$2"
            USE_LATEST=0
            shift 2
            ;;
        --latest)
            USE_LATEST=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# List backups if requested
if [ "$LIST_ONLY" -eq 1 ]; then
    list_backups
    exit 0
fi

# Get backup directory
if [ "$USE_LATEST" -eq 1 ]; then
    BACKUP_DIR=$(get_latest_backup)
    if [ -z "$BACKUP_DIR" ]; then
        log_error "No backups found"
        exit 1
    fi
    log_info "Using latest backup: $BACKUP_DIR"
fi

if [ -z "$BACKUP_DIR" ]; then
    log_error "No backup specified. Use --list to see available backups."
    show_help
    exit 1
fi

# Restore backup
restore_backup "$BACKUP_DIR" "$DRY_RUN"
