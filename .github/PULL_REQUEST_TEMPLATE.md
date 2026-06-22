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
- [ ] Repository infrastructure (.github/, .gitattributes, etc.)
- [ ] Other (explain below)

## What changed and why

<!-- Describe the change and the reasoning behind it. -->

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

## Shell safety / line endings

Shell scripts in this repo must use **LF line endings** (not CRLF).
If you edited on Windows, please verify your editor is configured for LF.

- [ ] I checked that changed `.sh` files have LF line endings
- [ ] I ran `bash -n <file>` on any changed shell scripts (syntax check)

## Documentation impact

- [ ] I updated relevant docs or added new docs
- [ ] The README or docs/ index still links to all relevant pages
- [ ] No docs changes needed

## Screenshots / terminal output

<!-- If your change affects the UI or CLI output, add screenshots or terminal recordings. -->

## Additional context

<!-- Anything else reviewers should know. -->
