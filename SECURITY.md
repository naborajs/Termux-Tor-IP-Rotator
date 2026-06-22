# Security Policy for Ghost Engine

Ghost Engine is a Tor-based privacy and proxy toolkit.
Because this project deals with network routing, proxy configuration, and identity management,
security considerations matter — both for the project itself and for how it's used.

---

## What qualifies as a security issue

Security-sensitive issues include:

- **Code execution vulnerabilities** — a way for an attacker to run arbitrary commands via Ghost Engine
- **Privilege escalation** — unintended privilege gain during install, update, or runtime
- **Data exposure** — unintended leaking of IP addresses, DNS queries, or identifying information
- **Tor / Privoxy configuration weaknesses** — incorrect defaults that could reduce anonymity
- **Process isolation failures** — PID files, temp files, or runtime data accessible to unauthorized users
- **Bootstrap / install integrity** — the install or update process downloading or executing untrusted content
- **Dependency confusion** — malicious packages replacing tor, privoxy, curl, or netcat through the installer

---

## What is NOT a security issue

Ghost Engine is a **learning and research tool** that helps users understand Tor routing and proxy workflows.
The following are explicitly **not** security issues:

- Ghost Engine does not make you anonymous (no tool can promise that)
- Using Ghost Engine with misconfigured browser settings, WebRTC leaks, or logged-in accounts
- Your ISP seeing that you're using Tor (Tor protocol is not designed to hide Tor usage)
- Website fingerprinting or traffic analysis
- Legal or ethical concerns about how someone chooses to use the tool
- General bugs that don't involve privilege, data exposure, or integrity

---

## Reporting a security vulnerability

**For non-sensitive bugs**, open a standard [GitHub Issue](https://github.com/naborajs/Termux-Tor-IP-Rotator/issues).

**For sensitive vulnerabilities** (code execution, privilege escalation, data leaks, integrity issues),
please report them privately so they can be addressed before public disclosure:

1. **Open a GitHub Issue** with a clear title but **do not include exploit details**
2. Or contact the maintainer through GitHub directly (see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md#maintainer-contact))

When reporting, include:
- What the issue is and its potential impact
- Steps to reproduce (without publishing a full exploit)
- Platform and environment details
- Suggested fix if you have one

---

## Response expectations

- Reports will be acknowledged within a reasonable timeframe
- The maintainer will assess severity and decide on a fix timeline
- Once fixed, a security advisory may be published on GitHub
- Public disclosure coordination is appreciated

---

## Responsible use reminder

Ghost Engine is intended for:
- Privacy research and education
- Network testing and troubleshooting
- Learning how Tor, SOCKS5, and HTTP proxies work
- Legitimate security testing on systems you own or have permission to test

Ghost Engine is **not** intended for:
- Illegal activity
- Evading law enforcement
- Harassment, stalking, or abuse
- Attacks against systems you do not own

Misuse of this tool is the responsibility of the user, not the project or its maintainers.
