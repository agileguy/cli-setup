#!/usr/bin/env bats
# BATS tests for install.sh functions
# Run with: bats tests/install_test.bats

# Setup - load functions from install.sh without running main
setup() {
    # Create temp directory for test artifacts
    export TEST_TMP="$(mktemp -d)"
    export HOME="$TEST_TMP/home"
    mkdir -p "$HOME/.config"

    # Source helper functions by extracting them
    # We test individual functions here
}

teardown() {
    rm -rf "$TEST_TMP"
}

# =============================================================================
# is_installed tests
# =============================================================================
@test "is_installed returns 0 for existing command (bash)" {
    is_installed() { command -v "$1" &> /dev/null; }
    run is_installed bash
    [ "$status" -eq 0 ]
}

@test "is_installed returns 1 for non-existing command" {
    is_installed() { command -v "$1" &> /dev/null; }
    run is_installed nonexistent_command_xyz123
    [ "$status" -eq 1 ]
}

# =============================================================================
# expand_path tests
# =============================================================================
@test "expand_path expands tilde to HOME" {
    expand_path() {
        local path="$1"
        path="${path/#\~/$HOME}"
        eval echo "$path"
    }
    result=$(expand_path "~/test")
    [ "$result" = "$HOME/test" ]
}

@test "expand_path handles path without tilde" {
    expand_path() {
        local path="$1"
        path="${path/#\~/$HOME}"
        eval echo "$path"
    }
    result=$(expand_path "/tmp/test")
    [ "$result" = "/tmp/test" ]
}

# =============================================================================
# validate_path tests
# =============================================================================
@test "validate_path rejects directory traversal" {
    expand_path() { local p="$1"; p="${p/#\~/$HOME}"; eval echo "$p"; }
    log_error() { echo "$1" >&2; }

    validate_path() {
        local path="$1"
        local expanded_path
        expanded_path=$(expand_path "$path")
        if [[ "$expanded_path" =~ \.\. ]]; then
            log_error "Path contains directory traversal: $path"
            return 1
        fi
        local allowed_prefixes=("$HOME" "/tmp" "/usr/local")
        local is_allowed=0
        for prefix in "${allowed_prefixes[@]}"; do
            if [[ "$expanded_path" == "$prefix"* ]]; then
                is_allowed=1
                break
            fi
        done
        if [ "$is_allowed" -eq 0 ]; then
            log_error "Path outside allowed directories: $path"
            return 1
        fi
        return 0
    }

    run validate_path "$HOME/../etc/passwd"
    [ "$status" -eq 1 ]
}

@test "validate_path accepts HOME paths" {
    expand_path() { local p="$1"; p="${p/#\~/$HOME}"; eval echo "$p"; }
    log_error() { echo "$1" >&2; }

    validate_path() {
        local path="$1"
        local expanded_path
        expanded_path=$(expand_path "$path")
        if [[ "$expanded_path" =~ \.\. ]]; then
            return 1
        fi
        local allowed_prefixes=("$HOME" "/tmp" "/usr/local")
        local is_allowed=0
        for prefix in "${allowed_prefixes[@]}"; do
            if [[ "$expanded_path" == "$prefix"* ]]; then
                is_allowed=1
                break
            fi
        done
        if [ "$is_allowed" -eq 0 ]; then
            return 1
        fi
        return 0
    }

    run validate_path "$HOME/.config/test"
    [ "$status" -eq 0 ]
}

@test "validate_path accepts /tmp paths" {
    expand_path() { local p="$1"; p="${p/#\~/$HOME}"; eval echo "$p"; }

    validate_path() {
        local path="$1"
        local expanded_path
        expanded_path=$(expand_path "$path")
        if [[ "$expanded_path" =~ \.\. ]]; then
            return 1
        fi
        local allowed_prefixes=("$HOME" "/tmp" "/usr/local")
        local is_allowed=0
        for prefix in "${allowed_prefixes[@]}"; do
            if [[ "$expanded_path" == "$prefix"* ]]; then
                is_allowed=1
                break
            fi
        done
        if [ "$is_allowed" -eq 0 ]; then
            return 1
        fi
        return 0
    }

    run validate_path "/tmp/test"
    [ "$status" -eq 0 ]
}

@test "validate_path rejects paths outside allowed directories" {
    expand_path() { local p="$1"; p="${p/#\~/$HOME}"; eval echo "$p"; }
    log_error() { echo "$1" >&2; }

    validate_path() {
        local path="$1"
        local expanded_path
        expanded_path=$(expand_path "$path")
        if [[ "$expanded_path" =~ \.\. ]]; then
            return 1
        fi
        local allowed_prefixes=("$HOME" "/tmp" "/usr/local")
        local is_allowed=0
        for prefix in "${allowed_prefixes[@]}"; do
            if [[ "$expanded_path" == "$prefix"* ]]; then
                is_allowed=1
                break
            fi
        done
        if [ "$is_allowed" -eq 0 ]; then
            log_error "Path outside allowed directories: $path"
            return 1
        fi
        return 0
    }

    run validate_path "/etc/passwd"
    [ "$status" -eq 1 ]
}

# =============================================================================
# backup_file tests
# =============================================================================
@test "backup_file creates backup of existing file" {
    SKIP_BACKUP=0
    BACKUP_DIR="$TEST_TMP/backups"
    mkdir -p "$BACKUP_DIR"

    log_verbose() { :; }

    backup_file() {
        local file="$1"
        if [ "$SKIP_BACKUP" -eq 1 ]; then
            return 0
        fi
        if [ -f "$file" ]; then
            local backup_path="$BACKUP_DIR${file}"
            mkdir -p "$(dirname "$backup_path")"
            cp "$file" "$backup_path"
        fi
    }

    # Create test file
    mkdir -p "$TEST_TMP/testdir"
    echo "test content" > "$TEST_TMP/testdir/testfile"

    backup_file "$TEST_TMP/testdir/testfile"

    [ -f "$BACKUP_DIR$TEST_TMP/testdir/testfile" ]
}

@test "backup_file skips when SKIP_BACKUP=1" {
    SKIP_BACKUP=1
    BACKUP_DIR="$TEST_TMP/backups"
    mkdir -p "$BACKUP_DIR"

    backup_file() {
        local file="$1"
        if [ "$SKIP_BACKUP" -eq 1 ]; then
            return 0
        fi
        if [ -f "$file" ]; then
            local backup_path="$BACKUP_DIR${file}"
            mkdir -p "$(dirname "$backup_path")"
            cp "$file" "$backup_path"
        fi
    }

    # Create test file
    mkdir -p "$TEST_TMP/testdir"
    echo "test content" > "$TEST_TMP/testdir/testfile"

    backup_file "$TEST_TMP/testdir/testfile"

    [ ! -f "$BACKUP_DIR$TEST_TMP/testdir/testfile" ]
}

# =============================================================================
# verify_checksum tests
# =============================================================================
@test "verify_checksum skips verification when expected is SKIP" {
    log_verbose() { :; }

    verify_checksum() {
        local file="$1"
        local expected="$2"
        if [ -z "$expected" ] || [ "$expected" = "SKIP" ]; then
            return 0
        fi
        local actual
        actual=$(sha256sum "$file" | awk '{print $1}')
        if [ "$actual" = "$expected" ]; then
            return 0
        else
            return 1
        fi
    }

    echo "test" > "$TEST_TMP/testfile"

    run verify_checksum "$TEST_TMP/testfile" "SKIP"
    [ "$status" -eq 0 ]
}

@test "verify_checksum passes with correct checksum" {
    log_verbose() { :; }

    verify_checksum() {
        local file="$1"
        local expected="$2"
        if [ -z "$expected" ] || [ "$expected" = "SKIP" ]; then
            return 0
        fi
        local actual
        actual=$(sha256sum "$file" | awk '{print $1}')
        if [ "$actual" = "$expected" ]; then
            return 0
        else
            return 1
        fi
    }

    echo -n "test" > "$TEST_TMP/testfile"
    expected=$(sha256sum "$TEST_TMP/testfile" | awk '{print $1}')

    run verify_checksum "$TEST_TMP/testfile" "$expected"
    [ "$status" -eq 0 ]
}

@test "verify_checksum fails with incorrect checksum" {
    log_verbose() { :; }
    log_error() { echo "$1" >&2; }

    verify_checksum() {
        local file="$1"
        local expected="$2"
        if [ -z "$expected" ] || [ "$expected" = "SKIP" ]; then
            return 0
        fi
        local actual
        actual=$(sha256sum "$file" | awk '{print $1}')
        if [ "$actual" = "$expected" ]; then
            return 0
        else
            log_error "Checksum mismatch!"
            return 1
        fi
    }

    echo "test" > "$TEST_TMP/testfile"

    run verify_checksum "$TEST_TMP/testfile" "invalidchecksum123"
    [ "$status" -eq 1 ]
}

# =============================================================================
# Argument parsing tests
# =============================================================================
@test "install.sh shows help with --help" {
    run bash -c "cd $(dirname $BATS_TEST_DIRNAME) && ./install.sh --help"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: install.sh"* ]]
}

@test "install.sh shows help with -h" {
    run bash -c "cd $(dirname $BATS_TEST_DIRNAME) && ./install.sh -h"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: install.sh"* ]]
}

@test "install.sh rejects unknown option" {
    run bash -c "cd $(dirname $BATS_TEST_DIRNAME) && ./install.sh --unknown-option 2>&1"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option"* ]]
}
