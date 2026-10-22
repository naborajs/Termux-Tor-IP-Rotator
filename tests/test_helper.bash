#!/usr/bin/env bash
#
# test_helper.bash - Common test utilities for Ghost Engine test suite
# Loaded by all .bats files via 'load test_helper'
#

# Path to the Ghost Engine script
GHOST_SCRIPT="${GHOST_SCRIPT:-$(cd "$(dirname "$BATS_TEST_DIRNAME")/.." && pwd)/ns-ghost.sh}"

# Extract a single function from ns-ghost.sh by name
# Usage: extract_function "function_name"
extract_function() {
    local func_name="$1"
    sed -n "/^${func_name}()/,/^}$/p" "$GHOST_SCRIPT"
}

# Create an isolated test environment with temp directories
setup_test_env() {
    export BASE_DIR="$(mktemp -d)"
    export CONFIG_FILE="$BASE_DIR/config.conf"
    export TOR_DIR="$BASE_DIR/tor_single"
    export LOG_FILE="$BASE_DIR/tor_debug.log"
    export TOR_PID_FILE="$BASE_DIR/tor.pid"
    export PRIVOXY_PID_FILE="$BASE_DIR/privoxy.pid"
    export PRIVOXY_CONF="$BASE_DIR/privoxy.conf"
    mkdir -p "$TOR_DIR/data"
    touch "$LOG_FILE"
}

# Tear down the test environment
teardown_test_env() {
    [[ -n "${BASE_DIR:-}" && -d "$BASE_DIR" ]] && rm -rf "$BASE_DIR"
}

# Write a config file with given key=value pairs
# Usage: write_config "KEY1=val1" "KEY2=val2"
write_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    {
        echo "# Ghost Engine test config"
        for line in "$@"; do
            echo "$line"
        done
    } > "$CONFIG_FILE"
}

# Assert a string contains a substring
assert_contains() {
    local haystack="$1" needle="$2"
    [[ "$haystack" == *"$needle"* ]]
}

# Assert a string matches a regex
assert_matches() {
    local haystack="$1" pattern="$2"
    [[ "$haystack" =~ $pattern ]]
}

# Assert exit code is zero
assert_success() {
    [[ "$status" -eq 0 ]]
}

# Assert exit code is non-zero
assert_failure() {
    [[ "$status" -ne 0 ]]
}
