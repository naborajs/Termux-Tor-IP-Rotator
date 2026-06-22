# Ghost Engine Quick Start Guide

Get up and running fast.

---

## What is Ghost Engine?

Ghost Engine is a Tor-powered privacy toolkit that lets you:

- Route traffic through Tor
- Rotate Tor identities and change exit IPs
- Verify Tor connectivity
- Use HTTP (Privoxy) and SOCKS5 proxies
- Monitor your current Tor identity

---

## Installation

```bash
git clone https://github.com/naborajs/Termux-Tor-IP-Rotator.git
cd Termux-Tor-IP-Rotator
sh bootstrap.sh install
```

> See [PLATFORMS.md](PLATFORMS.md) for platform-specific install details.

---

## Start Ghost Engine

```bash
ns-ghost
```

Or directly:

```bash
./ns-ghost.sh
```

---

## First-time setup

### Step 1 — Start the engine

From the menu, select:

```
1 ▶ Start Engine
```

Wait until you see:

```
TOR ONLINE
Proxy ONLINE
```

### Step 2 — Verify Tor

```
7 ▶ Verify TOR
```

Expected:

```
TOR Status : VERIFIED
```

### Step 3 — Check your current Tor IP

```
4 ▶ Current IP
```

Example output: `185.xxx.xxx.xxx`

### Step 4 — Rotate your identity

Single rotation:

```
3 ▶ Rotate Once
```

Automatic rotation:

```
2 ▶ Auto Rotate
```

Recommended interval: **15 seconds**

---

## Verify everything is working

Check your real IP:

```bash
curl https://api64.ipify.org
```

Check your Tor-routed IP:

```bash
curl --socks5 127.0.0.1:9050 https://api64.ipify.org
```

**Expected**: The two commands should return different IP addresses.

---

## Using the proxy

| Protocol | Address |
|----------|---------|
| HTTP Proxy | `127.0.0.1:8118` |
| SOCKS5 Proxy | `127.0.0.1:9050` |

---

## Quick health check

All commands below should work:

```bash
curl --socks5 127.0.0.1:9050 https://api64.ipify.org
ps aux | grep tor
ps aux | grep privoxy
```

If they work, Ghost Engine is operational.

---

## Next steps

Read the guide for your platform:

- [Termux Guide](docs/termux.txt)
- [WSL Guide](docs/wsl.txt)
- [Linux Guide](docs/linux.txt)

---

*Ghost Engine v5 — NS CODEX • Naboraj Sarkar (Nishant)*
