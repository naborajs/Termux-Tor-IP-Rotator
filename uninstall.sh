#!/usr/bin/env bash
# NABORAJ – GHOST ENGINE v5 Uninstaller

# Self-heal CRLF (portable): re-exec after stripping \r
if grep -q $'\r' "$0" 2>/dev/null; then
    tr -d '\r' < "$0" > "$0.tmp" 2>/dev/null || exit 1
    mv "$0.tmp" "$0" 2>/dev/null || exit 1
    exec bash "$0" "$@"
fi

set -euo pipefail

INSTALL_NAME="ns-ghost"
BASE_DIR="$HOME/.ns_ghost"

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
MAG="\e[35m"
BLUE="\e[34m"
WHITE="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"

PLATFORM="unknown"
BIN_DIR=""
REMOVED_ITEMS=0
CONFIRM_REMOVE_DATA=false

detect_platform() {

    if command -v termux-info >/dev/null 2>&1; then
        PLATFORM="termux"
        BIN_DIR="/data/data/com.termux/files/usr/bin"

    elif grep -qi microsoft /proc/version 2>/dev/null; then
        PLATFORM="wsl"
        BIN_DIR="$HOME/.local/bin"

    elif [[ "$(uname -s)" == "Linux" ]]; then
        PLATFORM="linux"
        BIN_DIR="$HOME/.local/bin"

    elif [[ "$(uname -s)" == "Darwin" ]]; then
        PLATFORM="macos"

        if [[ -d "/opt/homebrew/bin" ]]; then
            BIN_DIR="/opt/homebrew/bin"
        else
            BIN_DIR="/usr/local/bin"
        fi
    fi
}

print_header() {

    clear

    echo -e "${RED}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${RED}${BOLD}║              GHOST ENGINE v5 UNINSTALLER                 ║${RESET}"
    echo -e "${RED}${BOLD}║                 DANGER • PERMANENT ACTION                ║${RESET}"
    echo -e "${RED}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYAN}Platform:${RESET} ${PLATFORM}"
    echo -e "${CYAN}Primary Binary Path:${RESET} ${BIN_DIR:-UNKNOWN}/${INSTALL_NAME}"
    echo -e "${CYAN}Ghost Engine Data Path:${RESET} ${BASE_DIR}"
    echo
}

show_warning_block() {

    echo -e "${RED}${BOLD}⚠ WARNING: THIS WILL REMOVE GHOST ENGINE FROM THIS SYSTEM ⚠${RESET}"
    echo
    echo -e "${YELLOW}The uninstaller will try to remove:${RESET}"
    echo -e "  ${WHITE}•${RESET} Installed ${BOLD}${INSTALL_NAME}${RESET} launcher/binary"
    echo -e "  ${WHITE}•${RESET} Extra Ghost Engine launchers found in common bin paths"
    echo -e "  ${WHITE}•${RESET} ${BOLD}${BASE_DIR}${RESET} (Tor data, Privoxy config, logs, session files, IP history)"
    echo
    echo -e "${MAG}${BOLD}This is NOT reversible once the data folder is deleted.${RESET}"
    echo
}

confirm_uninstall() {

    show_warning_block

    echo -e "${YELLOW}First confirmation:${RESET}"
    read -r -p "Type 'yes' to continue uninstalling Ghost Engine: " ans1

    if [[ "$ans1" != "yes" ]]; then
        echo
        echo -e "${YELLOW}[CANCELLED] Uninstall aborted by user.${RESET}"
        exit 0
    fi

    echo
    echo -e "${RED}${BOLD}Final confirmation required.${RESET}"
    echo -e "${RED}This will permanently remove Ghost Engine files from this system.${RESET}"
    read -r -p "Type 'DELETE' to permanently continue: " ans2

    if [[ "$ans2" != "DELETE" ]]; then
        echo
        echo -e "${YELLOW}[CANCELLED] Uninstall aborted at final confirmation.${RESET}"
        exit 0
    fi

    echo
    echo -e "${GREEN}[OK] Confirmation accepted. Starting full Ghost Engine removal...${RESET}"
    echo
}

stop_services() {

    echo -e "${YELLOW}[1/5] Stopping Ghost Engine services...${RESET}"

    pkill -f "tor.*${BASE_DIR}" 2>/dev/null || true
    pkill -f "privoxy.*${BASE_DIR}" 2>/dev/null || true

    # Best-effort cleanup of local user processes
    pkill tor 2>/dev/null || true
    pkill privoxy 2>/dev/null || true

    echo -e "${GREEN}[OK] Running Tor/Privoxy processes stopped (if any).${RESET}"
    echo
}

remove_primary_binary() {

    echo -e "${YELLOW}[2/5] Removing primary Ghost Engine binary...${RESET}"

    if [[ -n "$BIN_DIR" && -f "$BIN_DIR/$INSTALL_NAME" ]]; then
        rm -f "$BIN_DIR/$INSTALL_NAME"
        echo -e "${GREEN}[OK] Removed:${RESET} $BIN_DIR/$INSTALL_NAME"
        ((REMOVED_ITEMS++))
    else
        echo -e "${YELLOW}[SKIP] Primary binary not found:${RESET} ${BIN_DIR}/${INSTALL_NAME}"
    fi

    echo
}

remove_extra_launchers() {

    echo -e "${YELLOW}[3/5] Removing extra launcher files...${RESET}"

    local found_extra=false
    local extra_paths=(
        "$HOME/.local/bin/$INSTALL_NAME"
        "/usr/local/bin/$INSTALL_NAME"
        "/usr/bin/$INSTALL_NAME"
    )

    local path

    for path in "${extra_paths[@]}"; do

        # Skip the main BIN_DIR target because it was already handled
        if [[ "$path" == "$BIN_DIR/$INSTALL_NAME" ]]; then
            continue
        fi

        if [[ -f "$path" ]]; then
            found_extra=true

            if [[ -w "$path" ]]; then
                rm -f "$path"
                echo -e "${GREEN}[OK] Removed extra launcher:${RESET} $path"
                ((REMOVED_ITEMS++))
            else
                echo -e "${YELLOW}[WARN] Found but no permission to remove:${RESET} $path"
            fi
        fi
    done

    if [[ "$found_extra" == false ]]; then
        echo -e "${YELLOW}[SKIP] No extra launcher files found.${RESET}"
    fi

    echo
}

remove_data_dir() {

    echo -e "${YELLOW}[4/5] Removing Ghost Engine data directory...${RESET}"
    echo -e "${CYAN}Target:${RESET} ${BASE_DIR}"
    echo

    if [[ ! -d "$BASE_DIR" ]]; then
        echo -e "${YELLOW}[SKIP] No Ghost Engine data directory found.${RESET}"
        echo
        return
    fi

    echo -e "${MAG}${BOLD}This will permanently delete:${RESET}"
    echo -e "  ${WHITE}•${RESET} Tor runtime data"
    echo -e "  ${WHITE}•${RESET} Privoxy configuration"
    echo -e "  ${WHITE}•${RESET} Logs"
    echo -e "  ${WHITE}•${RESET} IP history / session files"
    echo

    echo -e "${RED}${BOLD}Second safety confirmation for DATA deletion${RESET}"
    read -r -p "Type 'ERASE' to delete ${BASE_DIR}: " ans

    if [[ "$ans" == "ERASE" ]]; then
        rm -rf "$BASE_DIR"
        echo -e "${GREEN}[OK] Removed:${RESET} $BASE_DIR"
        ((REMOVED_ITEMS++))
        CONFIRM_REMOVE_DATA=true
    else
        echo -e "${YELLOW}[KEEP] Data directory preserved:${RESET} $BASE_DIR"
    fi

    echo
}

remove_repo_copy_hint() {

    echo -e "${YELLOW}[5/5] Repository folder cleanup note${RESET}"
    echo

    echo -e "${CYAN}Important:${RESET} This uninstaller removes the installed Ghost Engine binary and local data."
    echo -e "${CYAN}It does NOT automatically delete the Git repository folder you cloned.${RESET}"
    echo

    echo -e "${YELLOW}If you also want to delete the cloned repo folder itself, remove it manually.${RESET}"
    echo -e "Example:"
    echo -e "  ${BOLD}rm -rf ~/Termux-Tor-IP-Rotator${RESET}"
    echo
}

show_summary() {

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}${BOLD}GHOST ENGINE UNINSTALL COMPLETE${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    printf "%-18s %s\n" "Platform:" "$PLATFORM"
    printf "%-18s %s\n" "Binary Path:" "${BIN_DIR:-UNKNOWN}/${INSTALL_NAME}"
    printf "%-18s %s\n" "Data Path:" "$BASE_DIR"
    printf "%-18s %s\n" "Items Removed:" "$REMOVED_ITEMS"

    echo

    if [[ -f "$BIN_DIR/$INSTALL_NAME" ]]; then
        echo -e "${RED}[WARNING] Binary still exists:${RESET} $BIN_DIR/$INSTALL_NAME"
    else
        echo -e "${GREEN}[OK] Ghost Engine binary removed.${RESET}"
    fi

    if [[ -d "$BASE_DIR" ]]; then
        echo -e "${YELLOW}[INFO] Ghost Engine data directory still exists:${RESET} $BASE_DIR"
    else
        echo -e "${GREEN}[OK] Ghost Engine data directory removed.${RESET}"
    fi

    echo
    echo -e "${DIM}Tor/Privoxy packages were NOT uninstalled from the system.${RESET}"
    echo -e "${DIM}Only Ghost Engine launchers, processes, and local Ghost Engine data were targeted.${RESET}"
    echo
}

main() {

    detect_platform

    if [[ "$PLATFORM" == "unknown" ]]; then
        echo -e "${RED}[ERROR] Unsupported platform.${RESET}"
        exit 1
    fi

    print_header
    confirm_uninstall
    stop_services
    remove_primary_binary
    remove_extra_launchers
    remove_data_dir
    remove_repo_copy_hint
    show_summary
}

main "$@"