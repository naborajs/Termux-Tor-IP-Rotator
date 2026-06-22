# Ghost Engine Platform Guide

Ghost Engine runs on **Termux**, **Linux** (Debian/Ubuntu/Arch/Fedora), **macOS** (Intel + Apple Silicon), and **WSL/WSL2**.

---

## Platform comparison

| Feature | Termux | Linux | macOS | WSL/WSL2 |
|---------|--------|-------|-------|----------|
| Package manager | `pkg` | `apt`/`pacman`/`dnf` | `brew` | `apt` |
| Bin directory | `/data/data/.../usr/bin` | `~/.local/bin` | `/opt/homebrew/bin` or `/usr/local/bin` | `~/.local/bin` |
| sudo required | No | Yes | No | Yes |
| systemd | No | Yes (usually) | No | No |
| Wake lock | `termux-wake-lock` | N/A | N/A | N/A |
| Proxy host | `127.0.0.1` | `127.0.0.1` | `127.0.0.1` | WSL IP (varies) |

---

## Termux (Android)

**Install Termux from F-Droid** — the Play Store version is outdated and can break Ghost Engine.

```bash
pkg update -y && pkg upgrade -y
pkg install git -y
git clone https://github.com/naborajs/Termux-Tor-IP-Rotator.git
cd Termux-Tor-IP-Rotator
sh bootstrap.sh install
```

**Important:**
- Disable battery optimization for Termux
- Use `termux-wake-lock` to prevent Android from killing the process
- Some Android apps don't respect system proxy settings

---

## Linux (Debian / Ubuntu / Kali / Parrot)

```bash
sudo apt update
sudo apt install git -y
git clone https://github.com/naborajs/Termux-Tor-IP-Rotator.git
cd Termux-Tor-IP-Rotator
sh bootstrap.sh install
```

**What the installer does:**
- Disables system Tor/Privoxy services (prevents port conflicts)
- Installs Tor, Privoxy, curl, and netcat via apt
- Adds `~/.local/bin` to your PATH if needed
- Places `ns-ghost` in `~/.local/bin/`

**After install:** Open a new terminal or run `source ~/.bashrc`.

---

## macOS (Intel + Apple Silicon)

**Requires Homebrew:** [https://brew.sh](https://brew.sh)

```bash
brew install git
git clone https://github.com/naborajs/Termux-Tor-IP-Rotator.git
cd Termux-Tor-IP-Rotator
sh bootstrap.sh install
```

The installer installs Tor, Privoxy, curl, and netcat via Homebrew.

---

## WSL / WSL2

**Prerequisites:** WSL2 is recommended. If you are on WSL1, some networking features may differ.

```bash
sudo apt update
sudo apt install git -y
git clone https://github.com/naborajs/Termux-Tor-IP-Rotator.git
cd Termux-Tor-IP-Rotator
sh bootstrap.sh install
```

**WSL-specific notes:**
- The installer disables the Ubuntu system Tor/Privoxy services to prevent port conflicts
- When Ghost Engine starts, it detects WSL and shows the **Windows proxy address** to use
- Use that address (not `127.0.0.1`) when configuring Windows proxy settings
- If Windows internet stops after enabling proxy, use the correct WSL IP shown by Ghost Engine

**Finding your WSL IP manually:**
```bash
hostname -I
```

---

## Updating

```bash
cd Termux-Tor-IP-Rotator
sh bootstrap.sh update
```

This pulls the latest changes via git and re-runs the installer.

---

## Uninstalling

```bash
cd Termux-Tor-IP-Rotator
sh bootstrap.sh uninstall
```

This provides a two-phase confirmation (type `yes` + `DELETE`) and removes:
- The `ns-ghost` binary from your system
- Extra launchers found in common bin paths
- The `~/.ns_ghost` data directory (optionally)
