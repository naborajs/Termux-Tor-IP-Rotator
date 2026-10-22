#!/usr/bin/env bats

# test_health.bats - Unit tests for health check logic
# Tests: health_check scoring, detect_status, check_tor, check_privoxy

load '../test_helper'

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "health_check function exists and is callable" {
    # The function should be defined in the script
    extract_function "health_check" > /dev/null
    [ $? -eq 0 ]
}

@test "detect_status sets TOR_RUNNING variable" {
    detect_status
    # TOR_RUNNING should be set to something (true/false/UNKNOWN)
    [ -n "$TOR_RUNNING" ]
}

@test "detect_status sets PROXY_RUNNING variable" {
    detect_status
    [ -n "$PROXY_RUNNING" ]
}

@test "check_tor returns non-zero when tor is not running" {
    # With no tor process, check_tor should fail
    run check_tor
    [ "$status" -ne 0 ]
}

@test "check_privoxy returns non-zero when privoxy is not running" {
    run check_privoxy
    [ "$status" -ne 0 ]
}

@test "check_privoxy_port returns non-zero when port is closed" {
    # Port 99999 should never be open
    PRIVOXY_PORT=99999
    run check_privoxy_port
    [ "$status" -ne 0 ]
}

@test "health check max score is 7" {
    # The health check has 7 steps
    extract_function "health_check" | grep -q 'MAX_SCORE=7'
    [ $? -eq 0 ]
}

@test "health check covers all 7 steps" {
    # Verify all 7 check steps are present
    local func_body
    func_body=$(extract_function "health_check")

    echo "$func_body" | grep -q '\[1/7\]'
    echo "$func_body" | grep -q '\[2/7\]'
    echo "$func_body" | grep -q '\[3/7\]'
    echo "$func_body" | grep -q '\[4/7\]'
    echo "$func_body" | grep -q '\[5/7\]'
    echo "$func_body" | grep -q '\[6/7\]'
    echo "$func_body" | grep -q '\[7/7\]'
}

@test "health score calculation uses percentage" {
    extract_function "health_check" | grep -q 'HEALTH_SCORE.*SCORE.*100.*MAX_SCORE'
    [ $? -eq 0 ]
}

@test "health status thresholds are defined" {
    local func_body
    func_body=$(extract_function "health_check")

    echo "$func_body" | grep -q 'EXCELLENT'
    echo "$func_body" | grep -q 'GOOD'
    echo "$func_body" | grep -q 'DEGRADED'
    echo "$func_body" | grep -q 'CRITICAL'
}
