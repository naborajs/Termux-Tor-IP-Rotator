## Summary

<!--
  Explain what this PR does in one or two sentences.
  If it fixes an issue, include "Closes #123" or "Fixes #123".
-->

## Type of change

- [ ] Runtime (`ns-ghost.sh`) — core engine behavior
- [ ] Install / Update / Uninstall flow
- [ ] Bootstrap / cross-platform / CRLF safety
- [ ] CLI flags or command dispatch
- [ ] Documentation (README, docs/, templates)
- [ ] CI/CD workflows (.github/workflows/)
- [ ] Repository infrastructure (.github/, .gitattributes, etc.)
- [ ] Other (explain below)

## What changed and why

<!-- Describe the change, the problem it solves, and the reasoning behind it. -->

## How was it tested?

<!--
  List the platforms you tested on and how you verified the change.
  Ghost Engine runs on Termux, Linux, macOS, and WSL.
  If you couldn't test a platform, say so — that's okay.
-->

- [ ] Termux (Android)
- [ ] Linux (distro: __________)
- [ ] macOS
- [ ] WSL / WSL2

**Test steps:**
1. ...
2. ...

## Quality & safety checklist

- [ ] I checked that changed `.sh` files have **Unix LF line endings** (no CRLF `\r`)
- [ ] I ran `bash -n <file>` (and `sh -n <file>` for POSIX scripts) on changed shell scripts
- [ ] Process management is safely scoped (no global `pkill tor` or `pkill privoxy`)
- [ ] All automated CI checks pass

## Documentation impact

- [ ] I updated relevant docs or added new docs
- [ ] The README or docs/ index still links to all relevant pages
- [ ] No docs changes needed

## Screenshots / terminal output

<!-- If your change affects the UI or CLI output, add screenshots or terminal recordings. -->

## Additional context

<!-- Anything else reviewers should know. -->

