# Ghost Engine Release Process

This doc is for the project maintainer. It outlines how to prepare and publish a release.

---

## Versioning

Ghost Engine uses informal semantic versioning: `v5`, `v5.1`, etc.
There is no strict semver policy yet — version bumps reflect meaningful changes in functionality, stability, or UX.

---

## Before cutting a release

### 1. Verify the engine works

```bash
# Syntax check
bash -n ns-ghost.sh install.sh update.sh uninstall.sh bootstrap.sh

# Full install test
sh bootstrap.sh install
```

Start the engine and test:
- Engine starts without errors
- Tor + Privoxy come online
- IP check shows Tor-routed IP
- Single rotation works
- Auto-rotation starts/stops cleanly (CTRL+C prompts)
- Status panel displays correctly
- Health check passes all 7 steps
- Stop engine kills processes cleanly

### 2. Verify install/update/uninstall

```bash
# Install from clean state
sh bootstrap.sh install

# Test update path
sh bootstrap.sh update

# Test uninstall flow
sh bootstrap.sh uninstall
```

### 3. Check cross-platform concerns

- [ ] Line endings: all `.sh` files have LF, not CRLF
- [ ] `.gitattributes` covers all relevant file types
- [ ] No global `pkill tor` / `pkill privoxy` calls remain
- [ ] `detect_platform` is the single source of truth for platform detection

### 4. Review docs

- [ ] README is up to date with current features and CLI flags
- [ ] Troubleshooting guide reflects known issues
- [ ] Architecture doc is accurate
- [ ] CHANGELOG or release notes are prepared

---

## Creating a release

### 1. Update the version in the code

Update the version string in `ns-ghost.sh`:

```bash
ENGINE_VERSION="v5.1"
```

### 2. Tag the release

```bash
git tag -a v5.1 -m "Ghost Engine v5.1"
git push origin v5.1
```

### 3. Create a GitHub Release

1. Go to [Releases](https://github.com/naborajs/Termux-Tor-IP-Rotator/releases)
2. Click "Draft a new release"
3. Select the tag
4. Title: `Ghost Engine v5.1`
5. Write release notes (see below)
6. Publish

### 4. Write release notes

Release notes should cover:

- **Summary**: 1–2 sentences about what this release is
- **New features**: What was added
- **Fixes**: What was fixed
- **Breaking changes**: Anything users need to migrate
- **Platform notes**: Any platform-specific caveats
- **Credits**: Thank contributors by GitHub handle

---

## Release checklist template

```markdown
## Ghost Engine vX.Y

### Summary
_Brief description of this release._

### New
- _Feature description_

### Fixed
- _Bug fix description_

### Changed
- _Behavior change description_

### Platform notes
- _Any platform-specific information_

### Contributors
- @username for contribution description
```

---

## Post-release

- Verify the GitHub Release page looks correct
- Check that the repo's "Releases" badge updates
- If there are major changes, consider posting an update or note
