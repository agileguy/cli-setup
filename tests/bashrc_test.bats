#!/usr/bin/env bats
# BATS tests for .bashrc functions
# Run with: bats tests/bashrc_test.bats

setup() {
    export TEST_TMP="$(mktemp -d)"

    # Define the functions from .bashrc for testing
    _validate_input() {
        local input="$1"
        local pattern="$2"
        if [[ ! "$input" =~ $pattern ]]; then
            echo "Error: Invalid characters in input" >&2
            return 1
        fi
        return 0
    }
}

teardown() {
    rm -rf "$TEST_TMP"
}

# =============================================================================
# _validate_input tests
# =============================================================================
@test "_validate_input accepts alphanumeric input" {
    run _validate_input "Edmonton" '^[a-zA-Z0-9 ,_-]+$'
    [ "$status" -eq 0 ]
}

@test "_validate_input accepts spaces and hyphens" {
    run _validate_input "New York City" '^[a-zA-Z0-9 ,_-]+$'
    [ "$status" -eq 0 ]
}

@test "_validate_input accepts city, country format" {
    run _validate_input "London, UK" '^[a-zA-Z0-9 ,_-]+$'
    [ "$status" -eq 0 ]
}

@test "_validate_input rejects shell metacharacters" {
    run _validate_input "city;rm -rf /" '^[a-zA-Z0-9 ,_-]+$'
    [ "$status" -eq 1 ]
}

@test "_validate_input rejects backticks" {
    run _validate_input "\`whoami\`" '^[a-zA-Z0-9 ,_-]+$'
    [ "$status" -eq 1 ]
}

@test "_validate_input rejects command substitution" {
    run _validate_input '$(whoami)' '^[a-zA-Z0-9 ,_-]+$'
    [ "$status" -eq 1 ]
}

@test "_validate_input rejects pipe" {
    run _validate_input "city | cat /etc/passwd" '^[a-zA-Z0-9 ,_-]+$'
    [ "$status" -eq 1 ]
}

@test "_validate_input rejects ampersand" {
    run _validate_input "city & rm -rf /" '^[a-zA-Z0-9 ,_-]+$'
    [ "$status" -eq 1 ]
}

# =============================================================================
# weather function tests (simulated)
# =============================================================================
@test "weather function validates city name" {
    weather() {
        local city="${1:-edmonton}"
        if ! _validate_input "$city" '^[a-zA-Z0-9 ,_-]+$'; then
            echo "Error: City name contains invalid characters" >&2
            return 1
        fi
        echo "Weather for: $city"  # Simulated output
    }

    run weather "Edmonton"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Weather for: Edmonton"* ]]
}

@test "weather function rejects malicious city name" {
    weather() {
        local city="${1:-edmonton}"
        if ! _validate_input "$city" '^[a-zA-Z0-9 ,_-]+$'; then
            echo "Error: City name contains invalid characters" >&2
            return 1
        fi
        echo "Weather for: $city"
    }

    run weather "; cat /etc/passwd"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid characters"* ]]
}

@test "weather function defaults to edmonton" {
    weather() {
        local city="${1:-edmonton}"
        if ! _validate_input "$city" '^[a-zA-Z0-9 ,_-]+$'; then
            return 1
        fi
        echo "Weather for: $city"
    }

    run weather
    [ "$status" -eq 0 ]
    [[ "$output" == *"Weather for: edmonton"* ]]
}

# =============================================================================
# commit function tests (simulated)
# =============================================================================
@test "commit function requires message" {
    commit() {
        if [ -z "$1" ]; then
            echo "Error: Commit message required" >&2
            return 1
        fi
        local message="$*"
        if [[ "$message" =~ [\`] ]] || [[ "$message" =~ \$\( ]]; then
            echo "Error: Commit message contains unsafe characters" >&2
            return 1
        fi
        echo "Would commit: $message"
    }

    run commit
    [ "$status" -eq 1 ]
    [[ "$output" == *"Commit message required"* ]]
}

@test "commit function accepts normal message" {
    commit() {
        if [ -z "$1" ]; then
            return 1
        fi
        local message="$*"
        if [[ "$message" =~ [\`] ]] || [[ "$message" =~ \$\( ]]; then
            return 1
        fi
        echo "Would commit: $message"
    }

    run commit "Fix bug in authentication"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Fix bug in authentication"* ]]
}

@test "commit function rejects backticks" {
    commit() {
        if [ -z "$1" ]; then
            return 1
        fi
        local message="$*"
        if [[ "$message" =~ [\`] ]] || [[ "$message" =~ \$\( ]]; then
            echo "Error: Commit message contains unsafe characters" >&2
            return 1
        fi
        echo "Would commit: $message"
    }

    run commit 'Fix `whoami` issue'
    [ "$status" -eq 1 ]
    [[ "$output" == *"unsafe characters"* ]]
}

@test "commit function rejects command substitution" {
    commit() {
        if [ -z "$1" ]; then
            return 1
        fi
        local message="$*"
        if [[ "$message" =~ [\`] ]] || [[ "$message" =~ \$\( ]]; then
            echo "Error: Commit message contains unsafe characters" >&2
            return 1
        fi
        echo "Would commit: $message"
    }

    run commit 'Fix $(whoami) issue'
    [ "$status" -eq 1 ]
    [[ "$output" == *"unsafe characters"* ]]
}

@test "commit function accepts quotes in message" {
    commit() {
        if [ -z "$1" ]; then
            return 1
        fi
        local message="$*"
        if [[ "$message" =~ [\`] ]] || [[ "$message" =~ \$\( ]]; then
            return 1
        fi
        echo "Would commit: $message"
    }

    run commit "Fix 'quoted' issue"
    [ "$status" -eq 0 ]
}

@test "commit function accepts multiple words" {
    commit() {
        if [ -z "$1" ]; then
            return 1
        fi
        local message="$*"
        if [[ "$message" =~ [\`] ]] || [[ "$message" =~ \$\( ]]; then
            return 1
        fi
        echo "Would commit: $message"
    }

    run commit Add new feature for user authentication
    [ "$status" -eq 0 ]
    [[ "$output" == *"Add new feature for user authentication"* ]]
}
