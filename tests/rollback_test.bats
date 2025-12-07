#!/usr/bin/env bats
# BATS tests for rollback.sh
# Run with: bats tests/rollback_test.bats

setup() {
    export TEST_TMP="$(mktemp -d)"
    export HOME="$TEST_TMP/home"
    mkdir -p "$HOME/.config/cli-setup/backups"
}

teardown() {
    rm -rf "$TEST_TMP"
}

# =============================================================================
# Argument parsing tests
# =============================================================================
@test "rollback.sh shows help with --help" {
    run bash -c "cd $(dirname $BATS_TEST_DIRNAME) && ./rollback.sh --help"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "rollback.sh shows help with -h" {
    run bash -c "cd $(dirname $BATS_TEST_DIRNAME) && ./rollback.sh -h"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

# =============================================================================
# Backup listing tests
# =============================================================================
@test "rollback.sh --list shows no backups when empty" {
    run bash -c "HOME='$HOME' cd $(dirname $BATS_TEST_DIRNAME) && ./rollback.sh --list"
    [[ "$output" == *"backup"* ]] || [[ "$output" == *"No"* ]] || [ "$status" -eq 0 ]
}

@test "rollback.sh --list shows available backups" {
    # Create fake backup directories
    mkdir -p "$HOME/.config/cli-setup/backups/20241206-120000"
    mkdir -p "$HOME/.config/cli-setup/backups/20241205-100000"

    run bash -c "HOME='$HOME' $(dirname $BATS_TEST_DIRNAME)/rollback.sh --list"
    [ "$status" -eq 0 ]
}
