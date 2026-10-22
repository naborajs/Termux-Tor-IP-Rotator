#!/usr/bin/env bats

# test_pid.bats - Unit tests for PID management functions
# Tests: kill_pid_file, stop_ghost_tor, stop_ghost_privoxy, cleanup_on_exit

load '../test_helper'

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "kill_pid_file returns 0 when PID file does not exist" {
    run kill_pid_file "$NONEXISTENT_PID"
    [ "$status" -eq 0 ]
}

@test "kill_pid_file removes PID file after killing process" {
    # Start a dummy background process
    sleep 60 &
    local dummy_pid=$!
    echo "$dummy_pid" > "$TEST_PID_FILE"

    kill_pid_file "$TEST_PID_FILE"

    # PID file should be removed
    [ ! -f "$TEST_PID_FILE" ]

    # Clean up if process still exists
    kill "$dummy_pid" 2>/dev/null || true
}

@test "kill_pid_file handles stale PID file gracefully" {
    # Write a PID that doesn't exist (99999 is very unlikely)
    echo "99999" > "$TEST_PID_FILE"

    run kill_pid_file "$TEST_PID_FILE"
    [ "$status" -eq 0 ]

    # PID file should still be cleaned up
    [ ! -f "$TEST_PID_FILE" ]
}

@test "kill_pid_file handles non-numeric PID content" {
    echo "not_a_pid" > "$TEST_PID_FILE"

    run kill_pid_file "$TEST_PID_FILE"
    [ "$status" -eq 0 ]
}

@test "kill_pid_file handles empty PID file" {
    touch "$TEST_PID_FILE"

    run kill_pid_file "$TEST_PID_FILE"
    [ "$status" -eq 0 ]
}

@test "cleanup_on_exit does not crash with no running processes" {
    # cleanup_on_exit should handle a clean state without errors
    run cleanup_on_exit
    [ "$status" -eq 0 ]
}

@test "stop_ghost_tor handles missing tor PID file" {
    run stop_ghost_tor
    [ "$status" -eq 0 ]
}

@test "stop_ghost_privoxy handles missing privoxy PID file" {
    run stop_ghost_privoxy
    [ "$status" -eq 0 ]
}

@test "PID file path uses correct base directory" {
    [ "$TOR_PID_FILE" == "$BASE_DIR/tor.pid" ]
    [ "$PRIVOXY_PID_FILE" == "$BASE_DIR/privoxy.pid" ]
}
