#!/usr/bin/env bash
# NS GAMMING – GHOST ENGINE v5 Uninstaller

set -e

INSTALL_NAME="ns-ghost"
BASE_DIR="$HOME/.ns_ghost"

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
MAG="\e[35m"
RESET="\e[0m"
BOLD="\e[1m"

PLATFORM="unknown"
BIN_DIR=""
REMOVED_ITEMS=0

detect_platform() {

    if command -v termux-info >/dev/null 2>&1; then
        PLATFORM="termux"
        BIN_DIR="/data/data/com.termux/files/usr/bin"

    elif grep -qi microsoft /proc/version 2>/dev/null; then
        PLATFORM="wsl"
        BIN_DIR="$HOME/.local/bin"

    elif [[ "$(uname)" == "Linux" ]]; then
        PLATFORM="linux"
        BIN_DIR="$HOME/.local/bin"

    elif [[ "$(uname)" == "Darwin" ]]; then
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

    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║           GHOST ENGINE v5 UNINSTALLER             ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYAN}Platform:${RESET} ${PLATFORM}"
    echo -e "${CYAN}Binary Path:${RESET} ${BIN_DIR:-UNKNOWN}"
    echo -e "${CYAN}Data Path:${RESET} ${BASE_DIR}"
    echo
}

stop_services() {

    echo -e "${YELLOW}[1/4] Stopping Ghost Engine services...${RESET}"

    pkill -f "tor.*${BASE_DIR}" 2>/dev/null || true
    pkill -f "privoxy.*${BASE_DIR}" 2>/dev/null || true
    pkill tor 2>/dev/null || true
    pkill privoxy 2>/dev/null || true

    echo -e "${GREEN}[OK] Running Tor/Privoxy processes stopped (if any).${RESET}"
    echo
}

remove_binary() {

    echo -e "${YELLOW}[2/4] Removing installed binary...${RESET}"

    if [[ -n "$BIN_DIR" && -f "$BIN_DIR/$INSTALL_NAME" ]]; then
        rm -f "$BIN_DIR/$INSTALL_NAME"
        echo -e "${GREEN}[OK] Removed:${RESET} $BIN_DIR/$INSTALL_NAME"
        ((REMOVED_ITEMS++))
    else
        echo -e "${YELLOW}[SKIP] Binary not found:${RESET} ${BIN_DIR}/${INSTALL_NAME}"
    fi

    echo
}

remove_desktop_links() {

    echo -e "${YELLOW}[3/4] Checking extra launcher files...${RESET}"

    local FOUND_EXTRA=false

    if [[ -f "$HOME/.local/bin/$INSTALL_NAME" && "$HOME/.local/bin/$INSTALL_NAME" != "$BIN_DIR/$INSTALL_NAME" ]]; then
        rm -f "$HOME/.local/bin/$INSTALL_NAME"
        echo -e "${GREEN}[OK] Removed extra binary:${RESET} $HOME/.local/bin/$INSTALL_NAME"
        ((REMOVED_ITEMS++))
        FOUND_EXTRA=true
    fi

    if [[ -f "/usr/local/bin/$INSTALL_NAME" && "/usr/local/bin/$INSTALL_NAME" != "$BIN_DIR/$INSTALL_NAME" ]]; then
        if [[ -w "/usr/local/bin/$INSTALL_NAME" ]]; then
            rm -f "/usr/local/bin/$INSTALL_NAME"
            echo -e "${GREEN}[OK] Removed extra binary:${RESET} /usr/local/bin/$INSTALL_NAME"
            ((REMOVED_ITEMS++))
            FOUND_EXTRA=true
        else
            echo -e "${YELLOW}[INFO] Found /usr/local/bin/$INSTALL_NAME but no permission to remove.${RESET}"
            FOUND_EXTRA=true
        fi
    fi

    if [[ "$FOUND_EXTRA" == false ]]; then
        echo -e "${YELLOW}[SKIP] No extra launcher files found.${RESET}"
    fi

    echo
}

remove_data_dir() {

    echo -e "${YELLOW}[4/4] Ghost Engine data directory${RESET}"
    echo -e "Path: ${CYAN}${BASE_DIR}${RESET}"
    echo

    if [[ ! -d "$BASE_DIR" ]]; then
        echo -e "${YELLOW}[SKIP] No config / logs directory found.${RESET}"
        echo
        return
    fi

    echo -e "${MAG}This directory may contain:${RESET}"
    echo -e "  • Tor data"
    echo -e "  • Privoxy config"
    echo -e "  • Logs"
    echo -e "  • IP history / session files"
    echo

    read -r -p "Delete this directory too? Type 'yes' to confirm: " ans

    if [[ "$ans" == "yes" ]]; then
        rm -rf "$BASE_DIR"
        echo -e "${GREEN}[OK] Removed:${RESET} $BASE_DIR"
        ((REMOVED_ITEMS++))
    else
        echo -e "${YELLOW}[KEEP] Preserved:${RESET} $BASE_DIR"
    fi

    echo
}

show_summary() {

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}UNINSTALL COMPLETE${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    printf "%-18s %s\n" "Platform:" "$PLATFORM"
    printf "%-18s %s\n" "Binary Path:" "${BIN_DIR:-UNKNOWN}"
    printf "%-18s %s\n" "Data Path:" "$BASE_DIR"
    printf "%-18s %s\n" "Items Removed:" "$REMOVED_ITEMS"

    echo

    if [[ -f "$BIN_DIR/$INSTALL_NAME" ]]; then
        echo -e "${RED}[WARNING] Binary still exists:${RESET} $BIN_DIR/$INSTALL_NAME"
    else
        echo -e "${GREEN}[OK] Ghost Engine binary removed.${RESET}"
    fi

    if [[ -d "$BASE_DIR" ]]; then
        echo -e "${YELLOW}[INFO] Config/log directory still exists:${RESET} $BASE_DIR"
    else
        echo -e "${GREEN}[OK] Config/log directory removed.${RESET}"
    fi

    echo
    echo -e "${DIM}If you installed Tor/Privoxy manually for other purposes, they were NOT uninstalled.${RESET}"
    echo -e "${DIM}This uninstaller only removes Ghost Engine files and local data.${RESET}"
    echo
}

main() {

    detect_platform

    if [[ "$PLATFORM" == "unknown" ]]; then
        echo -e "${RED}[ERROR] Unsupported platform.${RESET}"
        exit 1
    fi

    print_header
    stop_services
    remove_binary
    remove_desktop_links
    remove_data_dir
    show_summary
}

main "$@"