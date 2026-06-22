# Ghost Engine Architecture

Understanding how Ghost Engine works internally — useful for contributors and curious users.

---

## High-level overview

Ghost Engine is a shell-based Tor + Privoxy management toolkit.
It manages Tor and Privoxy as child processes, monitors their health, and provides a terminal interface for controlling identity rotation.

```
  ┌──────────────────────────────────────────────────┐
  │                  ns-ghost.sh                      │
  │  ┌─────────┐  ┌──────────┐  ┌────────────────┐   │
  │  │ Service │  │ Rotation │  │ UI / Dashboard │   │
  │  │ Control │  │ Engine   │  │ / CLI dispatch │   │
  │  └────┬────┘  └────┬─────┘  └────────────────┘   │
  │       │            │                              │
  │  ┌────▼────┐  ┌────▼─────┐                       │
  │  │  Tor    │  │ Privoxy  │                       │
  │  │ :9050   │  │ :8118    │                       │
  │  │ :9051   │  │          │                       │
  │  └────┬────┘  └────┬─────┘                       │
  │       │            │                              │
  └───────┼────────────┼──────────────────────────────┘
          │            │
          ▼            ▼
      SOCKS5       HTTP Proxy
      (9050)       (8118)
          │            │
          └─────┬──────┘
                ▼
            Internet
           (via Tor)
```

---

## Component roles

### `ns-ghost.sh` — the engine

The main runtime. It is a single ~2600-line bash script that contains everything:

| Area | Functions | Responsibility |
|------|-----------|----------------|
| **Service control** | `start_tor_engine`, `stop_all`, `stop_ghost_tor`, `stop_ghost_privoxy`, `cleanup_on_exit` | Start/stop Tor and Privoxy, process management via PID files, trap cleanup |
| **Rotation** | `single_rotate`, `smart_rotate_loop`, `check_duplicate_ip` | Tor identity rotation (SIGNAL NEWNYM), auto-loop with recovery |
| **Health** | `health_check`, `check_tor`, `check_privoxy`, `detect_status` | Port checks, connectivity verification through Tor/Privoxy, 7-step health score |
| **Config** | `load_config`, `save_config` | Persistent settings via `~/.ns_ghost/config.conf` |
| **Platform** | `detect_platform` | Single source of truth for Termux/Linux/macOS/WSL detection |
| **UI/Menu** | `main_menu`, `banner`, `show_status`, `docs_screen`, `settings_menu`, `about_screen` | Interactive terminal interface |
| **CLI dispatch** | `main` (at bottom) | Routes CLI arguments (`start`, `stop`, `rotate`, `status`, etc.) to functions |
| **IP tracking** | `remember_ip`, `show_ip_history` | Session IP history, duplicate detection, unique count |

### `install.sh` — the installer

Handles platform detection, dependency installation, binary placement, PATH configuration, and conflict resolution with system Tor/Privoxy services.

### `update.sh` — the updater

Clones latest changes via git, re-fixes line endings, re-runs the installer.

### `uninstall.sh` — the uninstaller

Stops Ghost Engine processes, removes the binary from bin directories, optionally removes `~/.ns_ghost` data directory.

### `bootstrap.sh` — the bootstrap layer

POSIX `sh` script (no bash required). First thing it does is strip CRLF from all `.sh` files using `tr -d '\r'`. Then sets executable permissions and dispatches to install/update/uninstall.

---

## Runtime data directory

All runtime data lives in `~/.ns_ghost/`:

```
~/.ns_ghost/
├── config.conf          # Persistent settings (persists across sessions)
├── tor_debug.log        # Engine + Tor log output
├── tor.pid              # Tor process PID
├── privoxy.pid          # Privoxy process PID
├── runtime.lock         # Startup marker
├── .deps_installed      # Marker that dependencies were checked
├── tor_single/          # Isolated Tor instance
│   ├── torrc            # Generated Tor config
│   └── data/            # Tor runtime data (keys, state, cache)
└── privoxy.conf         # Generated Privoxy config
```

Key details:
- Tor runs as a **user process** (not systemd) using a custom `torrc` pointing to `tor_single/data/`
- Privoxy runs with a config that forwards SOCKS5 to Tor's local port
- The config file is a simple `KEY=VALUE` format sourced by `load_config`
- PID files enable scoped process management (no global `pkill tor`)

---

## Startup sequence

```
load_config          → Read ~/.ns_ghost/config.conf
security_hardening   → Create dirs, export HISTFILE, detect platform
install_deps         → Check/install tor, privoxy, curl, netcat
trap cleanup_on_exit → Trap EXIT/INT/TERM for clean shutdown
main "$@"            → Dispatch: CLI command → or interactive menu
```

---

## Identity rotation (how it works)

When you rotate your identity, Ghost Engine does:

```
SIGNAL NEWNYM via Control Port (9051)
          │
          ▼
    Wait 4-5 seconds
          │
          ▼
    Fetch IP through SOCKS5
    curl --socks5 127.0.0.1:9050 https://api64.ipify.org
          │
          ▼
    Compare with previous IP
          │
          ▼
    Log result, update statistics, store in IP history
```

The auto-rotation loop repeats this at a user-configurable interval (default 10s, minimum 3s) and includes:
- **Recovery**: if Tor or Privoxy dies during the loop, the engine attempts restart
- **Duplicate detection**: if the same IP appears 5+ consecutive times, the engine auto-restarts Tor
- **Graceful exit**: CTRL+C in auto-rotation prompts "Stop engine too?" and returns to menu

---

## Health check (7-step diagnostic)

The health check in `ns-ghost.sh` runs 7 checks and produces a score:

| # | Check | What it tests |
|---|-------|---------------|
| 1 | Internet | Can reach `api64.ipify.org` or `ifconfig.me` |
| 2 | Tor Service | SOCKS5 port 9050 is listening AND a curl through Tor succeeds |
| 3 | HTTP Proxy | Privoxy port 8118 is listening AND a curl through the proxy succeeds |
| 4 | SOCKS5 Port | `nc -z 127.0.0.1 9050` |
| 5 | Control Port | `nc -z 127.0.0.1 9051` |
| 6 | Exit Node | A Tor-routed curl returns an actual IP |
| 7 | Proxy Binding | (WSL) `ss` confirms 0.0.0.0:8118 binding |

Score: `(passes / 7) × 100%`. Status: EXCELLENT (100%), GOOD (≥80%), DEGRADED (≥50%), CRITICAL.

---

## Cross-platform detection

The centralized `detect_platform()` function sets three global variables:

| Variable | Values |
|----------|--------|
| `PLATFORM_TYPE` | `WSL`, `TERMUX`, `MACOS`, `ARCH`, `FEDORA`, `DEBIAN`, `LINUX` |
| `PLATFORM_NAME` | Human-readable with emoji: "🖥 WSL2", "📱 Android Termux", etc. |
| `PROXY_HOST` | WSL IP for WSL, `127.0.0.1` everywhere else |

Platform-specific behavior:
- **WSL**: Proxy binds on `0.0.0.0` and PROXY_HOST is set to the WSL instance's IP
- **Termux**: Uses `termux-wake-lock` to prevent Android from killing the process
- **macOS**: Homebrew-based package installation, no sudo needed
- **Linux**: System Tor/Privoxy services are disabled during install to prevent port conflicts

---

## CLI flag mode

`ns-ghost.sh` supports both interactive and non-interactive modes:

```bash
ns-ghost              # Interactive menu (default)
ns-ghost start        # Start engine (non-interactive)
ns-ghost stop         # Stop engine (non-interactive)
ns-ghost rotate       # Rotate identity once
ns-ghost status       # Print status panel
ns-ghost ip           # Show current IP
ns-ghost health       # Run health diagnostics
ns-ghost menu         # Interactive menu
```

---

## Process safety model

Ghost Engine v5 uses PID-based process management:

1. **PID files**: `tor.pid` and `privoxy.pid` capture the child process IDs at startup
2. **Scoped kills**: `kill_pid_file()` reads the PID, sends SIGTERM, waits, sends SIGKILL if needed
3. **Fallback**: If PID file is missing, a scoped `pkill -f` with the `BASE_DIR` path pattern is used
4. **Trap cleanup**: `cleanup_on_exit()` runs on EXIT/INT/TERM to ensure no orphaned processes
5. **No global kills**: Ghost Engine never runs `pkill tor` or `pkill privoxy` — only its own instances

---

## Config persistence

Settings survive restarts via `~/.ns_ghost/config.conf`:

```
# Ghost Engine persistent configuration
MAX_DUPLICATES=5
SHOW_MATRIX=true
AUTO_SAVE_LOGS=false
TOR_SOCKS_PORT=9050
TOR_CONTROL_PORT=9051
PRIVOXY_PORT=8118
```

The config is loaded by `load_config()` at startup and saved by `save_config()` whenever settings change.
