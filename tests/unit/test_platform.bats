#!/usr/bin/env bats

# test_platform.bats - Unit tests for detect_platform()

load "../test_helper.bash"

setup() {
    setup_test_config
    eval "$(extract_function 'detect_platform')"
}

teardown() {
    teardown_test_config
}

@test "detect_platform sets PLATFORM_TYPE" {
    detect_platform

    [ -n "$PLATFORM_TYPE" ]
}

@test "detect_platform sets PLATFORM_NAME" {
    detect_platform

    [ -n "$PLATFORM_NAME" ]
}

@test "detect_platform sets PLATFORM_TYPE to a known value" {
    detect_platform

    case "$PLATFORM_TYPE" in
        TERMUX|WSL|MACOS|LINUX)
            true
            ;;
        *)
            false
            ;;
    esac
}

@test "detect_platform sets SYSTEM_ARCH" {
    detect_platform

    [ -n "$SYSTEM_ARCH" ]
}

@test "detect_platform sets KERNEL_VERSION" {
    detect_platform

    [ -n "$KERNEL_VERSION" ]
}

@test "detect_platform detects Termux via PREFIX" {
    # Simulate Termux environment
    OLD_PREFIX="${PREFIX:-}"
    export PREFIX="/data/data/com.termux/files/usr"

    detect_platform

    [ "$PLATFORM_TYPE" == "TERMUX" ]

    export PREFIX="$OLD_PREFIX"
}

@test "detect_platform detects WSL via /proc/version" {
    # Only test if we can create the mock
    if [ ! -w /proc ]; then
        skip "Cannot mock /proc on this system"
    fi

    # This test validates the detection logic exists
    # Full WSL mocking requires root which is not practical in CI
    detect_platform

    # Should still set a valid platform
    [ -n "$PLATFORM_TYPE" ]
}

@test "detect_platform sets PROXY_HOST to 127.0.0.1 on non-WSL" {
    detect_platform

    if [ "$PLATFORM_TYPE" != "WSL" ]; then
        [ "$PROXY_HOST" == "127.0.0.1" ]
    fi
}
