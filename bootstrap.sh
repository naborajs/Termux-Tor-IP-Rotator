#!/bin/sh
# ==========================================================
# GHOST ENGINE v5 — Bootstrap Layer
# Fixes CRLF, sets permissions, dispatches sub-commands.
# Usage: sh bootstrap.sh [install|update|uninstall]
# ==========================================================

set -u

BOOTSTRAP_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Help / usage ────────────────────────────────────────────
print_usage() {
    cat <<EOF
Ghost Engine v5 — Bootstrap

Usage:  sh bootstrap.sh <command>

Commands:
    install     Install Ghost Engine on this system
    update      Pull latest version and re-install
    uninstall   Remove Ghost Engine from this system

If shell scripts have CRLF line endings (common after
editing on Windows), bootstrap will automatically fix them.

Examples:
    sh bootstrap.sh install
    sh bootstrap.sh update
    sh bootstrap.sh uninstall
EOF
}

# ── Portable CRLF cleanup ──────────────────────────────────
# Uses tr(1) instead of sed -i because:
#   - 'tr -d' is POSIX and available everywhere
#   - 'sed -i' has incompatible flags on GNU vs BSD
strip_crlf() {
    for _f in "$BOOTSTRAP_DIR"/*.sh; do
        [ -f "$_f" ] || continue
        tr -d '\r' < "$_f" > "$_f.tmp" 2>/dev/null || continue
        mv "$_f.tmp" "$_f" 2>/dev/null || rm -f "$_f.tmp"
    done
}

# ── Dispatch ────────────────────────────────────────────────
CMD="${1:-}"

case "$CMD" in
    install|update|uninstall)
        strip_crlf

        for _f in bootstrap.sh install.sh update.sh uninstall.sh ns-ghost.sh; do
            [ -f "$BOOTSTRAP_DIR/$_f" ] && chmod +x "$BOOTSTRAP_DIR/$_f" 2>/dev/null || true
        done

        if [ ! -f "$BOOTSTRAP_DIR/$CMD.sh" ]; then
            echo "[bootstrap] ERROR: Missing $CMD.sh — repository may be corrupted." >&2
            exit 1
        fi

        exec sh "$BOOTSTRAP_DIR/$CMD.sh"
        ;;

    *)
        print_usage
        [ -z "$CMD" ] && exit 0 || exit 1
        ;;
esac
