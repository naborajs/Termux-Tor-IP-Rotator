#!/usr/bin/env bats

# test_config.bats - Unit tests for load_config() and save_config()

load "../test_helper.bash"

setup() {
    setup_test_config

    # Source the config-related functions by extracting them
    eval "$(extract_function 'load_config')"
    eval "$(extract_function 'save_config')"
}

teardown() {
    teardown_test_config
}

@test "save_config creates a config file" {
    MAX_DUPLICATES=5
    SHOW_MATRIX=true
    AUTO_SAVE_LOGS=false
    TOR_SOCKS_PORT=9050
    TOR_CONTROL_PORT=9051
    PRIVOXY_PORT=8118
    EXIT_COUNTRY="any"

    save_config

    [ -f "$CONFIG_FILE" ]
}

@test "save_config writes correct values" {
    MAX_DUPLICATES=10
    SHOW_MATRIX=false
    AUTO_SAVE_LOGS=true
    TOR_SOCKS_PORT=9150
    TOR_CONTROL_PORT=9151
    PRIVOXY_PORT=8218
    EXIT_COUNTRY="US"

    save_config

    run cat "$CONFIG_FILE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"MAX_DUPLICATES=10"* ]]
    [[ "$output" == *"SHOW_MATRIX=false"* ]]
    [[ "$output" == *"AUTO_SAVE_LOGS=true"* ]]
    [[ "$output" == *"TOR_SOCKS_PORT=9150"* ]]
    [[ "$output" == *"EXIT_COUNTRY=US"* ]]
}

@test "load_config reads saved values" {
    cat > "$CONFIG_FILE" <<CFG
MAX_DUPLICATES=8
SHOW_MATRIX=false
AUTO_SAVE_LOGS=true
TOR_SOCKS_PORT=9200
TOR_CONTROL_PORT=9201
PRIVOXY_PORT=8300
EXIT_COUNTRY=DE
CFG

    MAX_DUPLICATES=5
    SHOW_MATRIX=true
    AUTO_SAVE_LOGS=false
    EXIT_COUNTRY="any"

    load_config

    [ "$MAX_DUPLICATES" -eq 8 ]
    [ "$SHOW_MATRIX" == "false" ]
    [ "$AUTO_SAVE_LOGS" == "true" ]
    [ "$TOR_SOCKS_PORT" -eq 9200 ]
    [ "$EXIT_COUNTRY" == "DE" ]
}

@test "load_config handles missing config file gracefully" {
    rm -f "$CONFIG_FILE"

    MAX_DUPLICATES=5
    load_config

    [ "$MAX_DUPLICATES" -eq 5 ]
}

@test "load_config rejects invalid MAX_DUPLICATES" {
    cat > "$CONFIG_FILE" <<CFG
MAX_DUPLICATES=notanumber
CFG

    MAX_DUPLICATES=5
    load_config

    [ "$MAX_DUPLICATES" -eq 5 ]
}

@test "load_config rejects MAX_DUPLICATES below 1" {
    cat > "$CONFIG_FILE" <<CFG
MAX_DUPLICATES=0
CFG

    MAX_DUPLICATES=5
    load_config

    [ "$MAX_DUPLICATES" -eq 5 ]
}

@test "load_config rejects invalid SHOW_MATRIX" {
    cat > "$CONFIG_FILE" <<CFG
SHOW_MATRIX=yes
CFG

    SHOW_MATRIX=true
    load_config

    [ "$SHOW_MATRIX" == "true" ]
}

@test "load_config skips comment lines" {
    cat > "$CONFIG_FILE" <<CFG
# This is a comment
MAX_DUPLICATES=7
# Another comment
CFG

    MAX_DUPLICATES=5
    load_config

    [ "$MAX_DUPLICATES" -eq 7 ]
}

@test "load_config handles empty config file" {
    touch "$CONFIG_FILE"

    MAX_DUPLICATES=5
    load_config

    [ "$MAX_DUPLICATES" -eq 5 ]
}

@test "load_config accepts valid EXIT_COUNTRY code" {
    cat > "$CONFIG_FILE" <<CFG
EXIT_COUNTRY=US
CFG

    EXIT_COUNTRY="any"
    load_config

    [ "$EXIT_COUNTRY" == "US" ]
}

@test "load_config accepts EXIT_COUNTRY=any" {
    cat > "$CONFIG_FILE" <<CFG
EXIT_COUNTRY=any
CFG

    EXIT_COUNTRY="US"
    load_config

    [ "$EXIT_COUNTRY" == "any" ]
}

@test "load_config rejects invalid EXIT_COUNTRY" {
    cat > "$CONFIG_FILE" <<CFG
EXIT_COUNTRY=USA
CFG

    EXIT_COUNTRY="any"
    load_config

    [ "$EXIT_COUNTRY" == "any" ]
}

@test "save then load roundtrip preserves values" {
    MAX_DUPLICATES=12
    SHOW_MATRIX=false
    AUTO_SAVE_LOGS=true
    TOR_SOCKS_PORT=9300
    TOR_CONTROL_PORT=9301
    PRIVOXY_PORT=8400
    EXIT_COUNTRY="FR"

    save_config

    MAX_DUPLICATES=1
    SHOW_MATRIX=true
    AUTO_SAVE_LOGS=false
    EXIT_COUNTRY="any"

    load_config

    [ "$MAX_DUPLICATES" -eq 12 ]
    [ "$SHOW_MATRIX" == "false" ]
    [ "$AUTO_SAVE_LOGS" == "true" ]
    [ "$EXIT_COUNTRY" == "FR" ]
}
