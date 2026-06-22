# Contributing to Ghost Engine

First — thank you for considering a contribution.
Ghost Engine started as a personal Termux privacy experiment and grew into a cross-platform toolkit.
Every issue filed, every doc clarified, every bug caught, every feature suggested — it all moves the project forward.

This guide covers how to contribute meaningfully, what the project expects, and how to avoid common pitfalls.

---

## Table of Contents

- [What kinds of contributions are welcome](#what-kinds-of-contributions-are-welcome)
- [Getting started](#getting-started)
- [Repository structure](#repository-structure)
- [Development workflow](#development-workflow)
- [Shell script guidelines](#shell-script-guidelines)
- [Cross-platform caveats](#cross-platform-caveats)
- [Line ending / CRLF safety](#line-ending--crlf-safety)
- [How to report bugs well](#how-to-report-bugs-well)
- [How to propose new features](#how-to-propose-new-features)
- [How to submit a pull request](#how-to-submit-a-pull-request)
- [Documentation changes](#documentation-changes)
- [Testing your changes](#testing-your-changes)

---

## What kinds of contributions are welcome

Ghost Engine is a shell-based Tor privacy toolkit.
Almost any improvement fits, as long as it respects the project's scope and identity:

- **Bug fixes** — anything broken in `ns-ghost.sh`, install, update, uninstall, or bootstrap
- **Documentation** — clearer README sections, better troubleshooting, more examples, platform-specific notes
- **Cross-platform hardening** — better WSL detection, Termux compatibility, macOS quirks
- **CLI / UX polish** — smarter menus, better error messages, faster dashboards, cleaner terminal output
- **Feature work** — new rotation strategies, health checks, config profiles, monitoring improvements
- **Process safety** — better PID handling, cleanup, traps, race-condition fixes
- **Shell script quality** — removing fragility, improving quoting, catching edge cases

Contributions that are **not** a good fit:
- Adding a GUI or TUI framework that depends on Node.js, Python, or other runtimes (Ghost Engine is a pure-shell project)
- Features that require non-free dependencies
- Changes that break the existing install/update/uninstall bootstrap flow without strong justification
- Adding donation links or self-promotion to the project

---

## Getting started

```bash
# Clone the repository
git clone https://github.com/naborajs/Termux-Tor-IP-Rotator.git
cd Termux-Tor-IP-Rotator

# Install Ghost Engine (uses bootstrap for CRLF safety)
sh bootstrap.sh install

# Or install directly
bash install.sh
```

The repository tracker is `ns-ghost.sh` — the entire engine lives in that single file.
Install, update, uninstall, and bootstrap are separate scripts that wrap around it.

---

## Repository structure

```
Termux-Tor-IP-Rotator/
├── .github/                    # Issue templates, PR template
│   └── ISSUE_TEMPLATE/
├── assets/                     # Screenshots for README
├── docs/                       # Extended documentation
│   ├── ARCHITECTURE.md         # How the engine works
│   ├── INSTALL.md              # Platform-specific install guides
│   ├── QUICKSTART.md           # Getting started quickly
│   ├── TROUBLESHOOTING.md      # Common issues and fixes
│   ├── PLATFORMS.md            # Platform-specific notes
│   └── RELEASING.md            # (maintainer) release workflow
├── ns-ghost.sh                 # The engine — main runtime
├── install.sh                  # Installer
├── update.sh                   # Updater
├── uninstall.sh                # Uninstaller
├── bootstrap.sh                # Bootstrap layer (CRLF fix + dispatch)
├── bootstrap.sh                # (see shell safety below)
├── CONTRIBUTING.md             # This file
├── SECURITY.md                 # Security reporting
├── SUPPORT.md                  # Support resources
├── CODE_OF_CONDUCT.md          # Community standards
├── README.md                   # Main landing page
├── .gitattributes              # Line ending enforcement
├── .editorconfig               # Editor defaults
└── .gitignore                  # File exclusions
```

---

## Development workflow

### Branches

The main development branch is `main`. Feature branches should be named descriptively:

```bash
git checkout -b fix/auto-rotate-crash
git checkout -b feat/config-profiles
git checkout -b docs/wsl-troubleshooting
```

### Commit style

Use clear, present-tense commit messages:

```
feat: add persistent config save on settings change
fix: prevent orphan tor processes on CTRL+C
docs: clarify WSL proxy host detection
refactor: consolidate platform detection into one function
```

Prefixes: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `style:`, `test:`.

### Before opening a PR

1. Make sure your shell scripts have **LF line endings** (see [CRLF safety](#line-ending--crlf-safety))
2. Run `bash -n` syntax check on changed shell files
3. Test the install flow at least once: `sh bootstrap.sh install`
4. If you changed runtime behavior, start the engine and verify the affected feature works
5. Update docs if your change affects user-facing behavior

---

## Shell script guidelines

Ghost Engine is written in **bash** (not POSIX sh), except `bootstrap.sh` which uses `#!/bin/sh` for maximum portability.

### Style conventions

- Use 4-space indentation (no tabs)
- Use `[[ ... ]]` for conditionals (bash-native, safer than `[ ... ]`)
- Quote variable expansions: `"$var"` not `$var`
- Prefer `local` for function-scoped variables
- Use `>/dev/null 2>&1` for silencing, not `&>/dev/null` (some older shells)
- Keep functions focused — if a function exceeds ~100 lines, consider splitting it
- Use `printf` for formatted output over `echo`

### Patterns to follow

**Option parsing with case:**
```bash
case "${1:-}" in
    start) ... ;;
    stop)  ... ;;
    *)     usage ;;
esac
```

**Portable CRLF cleanup (instead of `sed -i`):**
```bash
tr -d '\r' < "$file" > "$file.tmp" && mv "$file.tmp" "$file"
```

**PID-scoped process kill (instead of global `pkill`):**
```bash
kill_pid_file() {
    local pidfile="$1"
    [[ -f "$pidfile" ]] || return 0
    local pid; pid=$(cat "$pidfile" 2>/dev/null)
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null && kill "$pid" 2>/dev/null
    rm -f "$pidfile"
}
```

### What to avoid

- Global `pkill tor` / `pkill privoxy` — kills all tor/privoxy instances, not just Ghost Engine's
- Fixed temp file paths like `/tmp/ghost_response.txt` — use `mktemp`
- Platform detection by `grep -qi microsoft /proc/version` scattered in multiple functions — use the centralized `$PLATFORM_TYPE` variable instead
- Redundant network calls in menu rendering — cache status where possible

---

## Cross-platform caveats

Ghost Engine runs on **Termux**, **Linux** (Debian/Ubuntu/Arch/Fedora), **macOS** (Intel + Apple Silicon), and **WSL/WSL2**.

| Platform | Package manager | Bin dir | Notes |
|----------|---------------|---------|-------|
| Termux | `pkg` | `/data/data/com.termux/files/usr/bin` | Install from F-Droid, not Play Store |
| Debian/Ubuntu | `apt` | `~/.local/bin` | May need `sudo` |
| Arch | `pacman` | `~/.local/bin` | |
| Fedora | `dnf` | `~/.local/bin` | |
| macOS | `brew` | `/opt/homebrew/bin` or `/usr/local/bin` | Requires Homebrew |
| WSL/WSL2 | `apt` | `~/.local/bin` | Windows proxy config required |

When making changes, consider:
- **Termux**: No systemd, no `sudo`, no `/proc` in some configurations
- **macOS**: `sed -i` requires an empty backup extension (`sed -i ''`), `grep` behaves differently
- **WSL**: WSL1 vs WSL2 have different networking behavior; `hostname -I` may not work; proxy host detection is critical
- **Busybox**: Some Linux environments and Termux use Busybox utilities with reduced feature sets

---

## Line ending / CRLF safety

**This is the most common cross-platform issue.**

Shell scripts **must** use Unix (LF) line endings, not Windows (CRLF).
Editing shell files on Windows and running them on WSL/Linux will cause:

```
$'\r': command not found
invalid option name: pipefail
syntax error near unexpected token '{\r'
```

### How Ghost Engine prevents this

| Layer | What it does |
|-------|-------------|
| `.gitattributes` | Forces LF line endings for all `.sh` files in the repo |
| `.editorconfig` | Tells editors (VS Code, vim, etc.) to save shell files with LF |
| `bootstrap.sh` | Strips CR from all shell scripts before dispatching |
| Self-heal in each script | Every `.sh` file checks for CRLF at startup and re-execs after cleaning |

### What you need to do

1. **Configure your editor** to save shell files with LF line endings
2. After editing on Windows, run `sh bootstrap.sh install` which auto-fixes CRLF
3. Before committing, verify: `git diff --ignore-space-at-eol` shows only your real changes

If the bootstrap itself has CRLF issues:

```bash
find . -name '*.sh' -exec sh -c 'tr -d "\r" < "$1" > "$1.tmp" && mv "$1.tmp" "$1"' _ {} \;
```

---

## How to report bugs well

A good bug report includes:

1. **Platform** — Termux, Linux distro + version, macOS, WSL1 or WSL2
2. **Install method** — `sh bootstrap.sh install`, `bash install.sh`, or manual
3. **What happened** — exact error message or unexpected behavior
4. **What you expected** — clear description of correct behavior
5. **Steps to reproduce** — numbered steps from a fresh state
6. **Logs or output** — terminal output, health check results, anything relevant
7. **Commit hash** — run `git log --oneline -1` from the repo

Use the [Bug Report template](https://github.com/naborajs/Termux-Tor-IP-Rotator/issues/new/choose) — it covers all of this.

---

## How to propose new features

Before implementing a large feature, open a [Feature Request](https://github.com/naborajs/Termux-Tor-IP-Rotator/issues/new/choose) first.
This avoids wasted effort if the feature doesn't fit the project's direction.

Good feature proposals explain:
- The problem you're solving (not just the solution you want)
- Why it fits Ghost Engine (Tor routing, proxy workflows, privacy tooling)
- What area it affects (runtime, CLI, install, docs, cross-platform)

---

## How to submit a pull request

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-change`
3. Make your changes
4. Run `bash -n` on changed shell files
5. Verify CRLF safety (LF line endings)
6. Test install flow: `sh bootstrap.sh install`
7. Test the affected feature
8. Update docs if needed
9. Push and open a PR using the [PR template](https://github.com/naborajs/Termux-Tor-IP-Rotator/blob/main/.github/PULL_REQUEST_TEMPLATE.md)

Keep PRs focused on a single concern. If you have multiple unrelated changes, open separate PRs.

---

## Documentation changes

If your change affects user-facing behavior, update:
- The relevant section in `README.md`
- Platform-specific docs in `docs/` if needed
- The [Troubleshooting Guide](docs/TROUBLESHOOTING.md) if you're fixing a common problem

Documentation files use Markdown (.md).
When linking between docs, use relative paths: `[Troubleshooting Guide](docs/TROUBLESHOOTING.md)`.

---

## Testing your changes

Ghost Engine doesn't have an automated test suite yet (contributions welcome).
Manual testing should cover:

1. **Syntax**: `bash -n ns-ghost.sh install.sh update.sh uninstall.sh bootstrap.sh`
2. **Install flow**: `sh bootstrap.sh install` from a clean state
3. **Runtime**: Start the engine, verify Tor + Privoxy start, check status, perform a rotation
4. **Stop**: Verify engine stops cleanly (no orphan processes)
5. **Cross-platform**: Ideally test on at least one Linux environment and WSL if possible
6. **Edge cases**: Run with no internet, run with Tor already running, run the settings menu

---

## Code of Conduct

All contributors are expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
Be respectful, constructive, and focused on improving the project.

---

*Ghost Engine is built for learning, privacy, and the craft of shell engineering.
If you're here to contribute — welcome. This project exists because people like you helped make it better.*
