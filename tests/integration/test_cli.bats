#!/usr/bin/env bats

# ============================================================================
# test_cli.bats — Integration tests for the Ghost Engine CLI interface
#
# These tests invoke ns-ghost.sh directly and verify command-line parsing,
# help output, and exit codes. They do NOT require Tor or Privoxy to be
# installed — only that the script itself handles arguments correctly.
# ============================================================================

load '../test_helper'

setup() {
    setup_test_config
}

teardown() {
    teardown_test_config
}

# ------------------------------------------------------------------
# Help / Usage
# ------------------------------------------------------------------

@test "unknown command prints usage and exits 1" {
    run bash "$GHOST_SCRIPT" --invalid-flag
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"ns-ghost"* ]]
}

@test "help text lists all core commands" {
    run bash "$GHOST_SCRIPT" --invalid-flag
    [[ "$output" == *"start"* ]]
    [[ "$output" == *"stop"* ]]
    [[ "$output" == *"rotate"* ]]
    [[ "$output" == *"status"* ]]
    [[ "$output" == *"ip"* ]]
    [[ "$output" == *"health"* ]]
}

@test "help text mentions exit country feature" {
    run bash "$GHOST_SCRIPT" --invalid-flag
    [[ "$output" == *"config"* ]]
    [[ "$output" == *"exit-country"* ]]
}

# ------------------------------------------------------------------
# Config command (exit country)
# ------------------------------------------------------------------

@test "config exit-country with valid code sets country" {
    run bash "$GHOST_SCRIPT" config exit-country US
    [ "$status" -eq 0 ]
    [[ "$output" == *"US"* ]]
}

@test "config exit-country with lowercase code works" {
    run bash "$GHOST_SCRIPT" config exit-country de
    [ "$status" -eq 0 ]
    [[ "$output" == *"DE"* ]]
}

@test "config exit-country any resets to default" {
    run bash "$GHOST_SCRIPT" config exit-country any
    [ "$status" -eq 0 ]
    [[ "$output" == *"any"* ]]
}

@test "config exit-country with invalid code fails" {
    run bash "$GHOST_SCRIPT" config exit-country ZZ
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid"* ]]
}

@test "config exit-country with 3-letter code fails" {
    run bash "$GHOST_SCRIPT" config exit-country USA
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid"* ]]
}

@test "config exit-country with empty value fails" {
    run bash "$GHOST_SCRIPT" config exit-country ""
    [ "$status" -eq 1 ]
}

# ------------------------------------------------------------------
# Rotate with --country flag
# ------------------------------------------------------------------

@test "rotate --country with valid code is accepted" {
    # This will fail to start Tor (not installed in CI) but should
    # at least parse the --country flag without error
    run bash "$GHOST_SCRIPT" rotate --country FR
n    # Exit code may be non-zero if Tor is not installed,
    # but the flag should be parsed (no usage error)
    [[ "$output" != *"Usage:"* ]]
}

# ------------------------------------------------------------------
# Syntax validation
# ------------------------------------------------------------------

@test "script passes bash -n syntax check" {
    run bash -n "$GHOST_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script has no CRLF line endings" {
    run grep -c $'\r' "$GHOST_SCRIPT"
    [ "$status" -eq 1 ]
    [ "$output" -eq 0 ]
}

@test "script has valid shebang" {
    run head -1 "$GHOST_SCRIPT"
    [[ "$output" == "#!/usr/bin/env bash" ]]
}

@test "script contains CRLF self-heal guard" {
    run head -5 "$GHOST_SCRIPT"
    [[ "$output" == *"grep -q $'\r'"* ]]
}

# ------------------------------------------------------------------
# Config persistence
# ------------------------------------------------------------------

@test "config exit-country persists to config file" {
    bash "$GHOST_SCRIPT" config exit-country JP >/dev/null 2>&1
    [ -f "$CONFIG_FILE" ]
    run grep "EXIT_COUNTRY=JP" "$CONFIG_FILE"
    [ "$status" -eq 0 ]
}

@test "config exit-country any persists to config file" {
    bash "$GHOST_SCRIPT" config exit-country any >/dev/null 2>&1
    [ -f "$CONFIG_FILE" ]
    run grep "EXIT_COUNTRY=any" "$CONFIG_FILE"
    [ "$status" -eq 0 ]
}
