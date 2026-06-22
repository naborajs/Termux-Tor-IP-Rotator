# Ghost Engine Troubleshooting Guide

Common issues, explanations, and fixes.

---

## Ghost Engine starts but Verify TOR says OFFLINE

**Possible causes:**
- No internet connection
- Tor failed to start
- SOCKS port not open
- Firewall interference

**Checks:**

```bash
ps aux | grep tor
ss -tlnp | grep 9050
```

**Expected:** Tor process running, port 9050 listening.

**Fix:** Restart Ghost Engine → Option 1 (Start Engine).

---

## My browser still shows my real IP

**Possible causes:**
- Browser not using the proxy
- Wrong proxy address or port
- Browser was launched before the proxy was configured

**Fix:**

Verify your proxy settings:

| Setting | Value |
|---------|-------|
| HTTP Proxy | `127.0.0.1:8118` |
| (WSL) HTTP Proxy | `WSL_IP_ADDRESS:8118` |

Then visit: [https://check.torproject.org](https://check.torproject.org)

---

## Terminal IP changes but browser IP does not

Terminal and browser use separate network paths unless the browser is configured to use the proxy.

```
Terminal → Tor → Internet       (IP changes)
Browser  → Direct → Internet    (IP stays real)
```

**Fix:** Configure your browser's proxy settings to point at Ghost Engine.

---

## Internet stops working after enabling proxy

**Possible causes:**
- Ghost Engine stopped running
- Wrong proxy address
- Privoxy crashed

**Fix:**

1. Disable the system/browser proxy
2. Restart Ghost Engine: `ns-ghost start`
3. Verify Privoxy: `ps aux | grep privoxy`
4. Re-enable proxy with the correct address

---

## Why do I keep getting the same Tor IP?

Tor does not guarantee a new exit node on every rotation. It may reuse:

- Exit nodes
- Circuits
- Relays

This is normal Tor behavior, not a bug.

**Fix:** Increase rotation interval to 30–60 seconds for better variety.

---

## Auto-rotation stopped working

**Possible causes:**
- Tor crashed
- Android killed Termux (battery optimization)
- Control port unavailable

**Fix:** Restart Ghost Engine.

**Termux users:** Run `termux-wake-lock` and disable battery optimization for Termux.

---

## WSL proxy does not work

**Most common cause:** Using `127.0.0.1` instead of the WSL instance's IP.

**Find your WSL IP:**

```bash
hostname -I
```

**Example:** `172.25.56.176`

Use: `172.25.56.176:8118` as the proxy address (not `127.0.0.1`).

---

## Windows loses internet after proxy setup

Windows is forwarding traffic to a proxy that isn't responding.

**Fix:**
1. Disable Windows manual proxy
2. Restart Ghost Engine
3. Re-enable the proxy with the correct address shown in Ghost Engine's startup guide

---

## Ghost Engine says Proxy OFFLINE

**Check:**
```bash
ps aux | grep privoxy
ss -tlnp | grep 8118
```

**Fix:** Restart Ghost Engine.

---

## What ports does Ghost Engine use?

| Service | Port |
|---------|------|
| SOCKS5 | 9050 |
| Control Port | 9051 |
| HTTP Proxy (Privoxy) | 8118 |

---

## How do I check if Tor is running?

```bash
ps aux | grep tor
```

Expected: Tor process visible.

---

## How do I check if Privoxy is running?

```bash
ps aux | grep privoxy
```

Expected: Privoxy process visible.

---

## Is Ghost Engine a VPN?

**No.** Ghost Engine uses **Tor** (The Onion Router), not a VPN. They work differently:
- A VPN routes all traffic through a single server
- Tor routes traffic through three randomly selected relays

You can use both together: `You → VPN → Tor (Ghost Engine) → Internet`

---

## Does Ghost Engine make me anonymous?

**No tool can guarantee complete anonymity.**

Ghost Engine improves network privacy by routing traffic through Tor and rotating exit IPs.
You can still expose yourself by:

- Logging into personal accounts
- Sharing personal information
- Using services tied to your identity
- Browser fingerprinting and WebRTC leaks

---

## Quick health checklist

- [ ] Verify TOR = VERIFIED
- [ ] Tor process running
- [ ] Privoxy process running
- [ ] Tor IP differs from real IP
- [ ] [check.torproject.org](https://check.torproject.org) confirms Tor

If all checks pass, Ghost Engine is fully operational.

---

*Ghost Engine v5 — NS CODEX • Naboraj Sarkar (Nishant)*
