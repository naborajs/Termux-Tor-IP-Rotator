# Ghost Engine Test Suite

Automated tests using [bats-core](https://github.com/bats-core/bats-core).

## Structure

```
tests/
├── test_helper.bash          # Shared setup/teardown + assertion helpers
├── unit/
│   ├── test_config.bats      # load_config / save_config round-trip
│   ├── test_platform.bats    # detect_platform on different OS
│   ├── test_pid.bats         # kill_pid_file lifecycle
│   └── test_health.bats      # health_check scoring logic
└── integration/
    └── test_cli.bats         # CLI parsing, exit codes, config persistence
```

## Running Tests

### Prerequisites

```bash
# Install bats-core
git clone https://github.com/bats-core/bats-core.git
cd bats-core && ./install.sh ~/.local

# Install bats-support and bats-assert (optional, for richer output)
git clone https://github.com/bats-core/bats-support.git /tmp/bats-support
git clone https://github.com/bats-core/bats-assert.git /tmp/bats-assert
```

### Run All Tests

```bash
bats tests/
```

### Run a Single Suite

```bash
bats tests/unit/test_config.bats
```

### Run with TAP Output

```bash
bats --tap tests/
```

## CI Integration

Tests run automatically on every push and pull request via GitHub Actions.
See `.github/workflows/ci.yml` for the pipeline definition.

## Writing New Tests

1. Create a `.bats` file in the appropriate directory (`unit/` or `integration/`)
2. Load the test helper: `load '../test_helper'`
3. Use `setup()` and `teardown()` for isolated test environments
4. Use `run` to execute commands and `$status` / `$output` for assertions
5. Keep tests fast — mock external dependencies (Tor, Privoxy, network)

## ShellCheck

All shell scripts are linted with ShellCheck in CI. Configuration is in `.shellcheckrc`.

```bash
shellcheck ns-ghost.sh install.sh update.sh uninstall.sh bootstrap.sh
```
