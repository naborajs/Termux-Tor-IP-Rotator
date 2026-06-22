# Getting Help with Ghost Engine

There are several ways to get help depending on what you need.

---

## 📖 Read the docs first

Most common questions are already answered:

| Resource | What it covers |
|----------|---------------|
| [README](../README.md) | Project overview, quick install, FAQ, troubleshooting |
| [Install Guide](docs/INSTALL.md) | Platform-specific install instructions |
| [Quickstart Guide](docs/QUICKSTART.md) | Getting started quickly |
| [Troubleshooting Guide](docs/TROUBLESHOOTING.md) | Common issues and fixes |
| [FAQ](../README.md#-frequently-asked-questions) | Frequently asked questions in README |

---

## 🐛 Report a bug

If you've found something broken:

1. Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md) — it may already have a fix
2. Search [existing issues](https://github.com/naborajs/Termux-Tor-IP-Rotator/issues) to avoid duplicates
3. Open a [Bug Report](https://github.com/naborajs/Termux-Tor-IP-Rotator/issues/new/choose) with:
   - Platform (Termux / Linux / macOS / WSL)
   - Install method
   - What happened vs what you expected
   - Steps to reproduce
   - Terminal output or health check results

---

## 💡 Suggest a feature

If you have an idea for improvement:

1. Check [existing feature requests](https://github.com/naborajs/Termux-Tor-IP-Rotator/issues?q=is%3Aissue+label%3Aenhancement) for similar ideas
2. Open a [Feature Request](https://github.com/naborajs/Termux-Tor-IP-Rotator/issues/new/choose) with:
   - The problem you're solving
   - Your proposed solution
   - Why it fits Ghost Engine

---

## ❓ Questions

If you have a question that isn't covered by the docs or existing issues:

- **Open a GitHub Issue** with "question" in the title
- Be specific about what you're trying to do and what isn't working

---

## 🔒 Security issues

If you've found a security-sensitive issue:

- Do **not** open a public issue with exploit details
- See [SECURITY.md](SECURITY.md) for reporting guidance

---

## 🤝 Contributing

If you want to contribute code:

- Start with [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide
- Read the [Code of Conduct](CODE_OF_CONDUCT.md)
- Open a [Pull Request](https://github.com/naborajs/Termux-Tor-IP-Rotator/pulls)

---

## ⚡ Quick recovery

If Ghost Engine won't start or acts broken:

```bash
# Fix CRLF issues
find . -name '*.sh' -exec sh -c 'tr -d "\r" < "$1" > "$1.tmp" && mv "$1.tmp" "$1"' _ {} \;

# Reinstall via bootstrap
sh bootstrap.sh install
```

---

*Ghost Engine is maintained by a solo developer.
Please be patient, and include as much detail as possible when asking for help.*
