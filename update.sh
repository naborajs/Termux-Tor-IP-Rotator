#!/usr/bin/env bash
# NABORAJ – GHOST ENGINE v5 Updater

set -euo pipefail

REPO_URL="https://github.com/naborajs/Termux-Tor-IP-Rotator.git"
REPO_NAME="Termux-Tor-IP-Rotator"
SCRIPT_NAME="ns-ghost.sh"
INSTALL_SCRIPT="install.sh"

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
MAG="\e[35m"
RESET="\e[0m"
BOLD="\e[1m"

PLATFORM="unknown"
REPO_ROOT=""
CURRENT_BRANCH=""
CURRENT_COMMIT=""
NEW_COMMIT=""

detect_platform() {
    if command -v termux-info >/dev/null 2>&1; then
        PLATFORM="termux"
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        PLATFORM="wsl"
    elif [[ "$(uname -s)" == "Linux" ]]; then
        PLATFORM="linux"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        PLATFORM="macos"
    else
        PLATFORM="unknown"
    fi
}

print_header() {
    clear

    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║              GHOST ENGINE v5 UPDATER              ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYAN}Platform:${RESET} ${PLATFORM}"
    echo -e "${CYAN}Repository:${RESET} ${REPO_URL}"
    echo
}

check_requirements() {
    echo -e "${YELLOW}[1/6] Checking requirements...${RESET}"

    if ! command -v git >/dev/null 2>&1; then
        echo -e "${RED}[ERROR] Git is not installed.${RESET}"
        exit 1
    fi

    if ! command -v bash >/dev/null 2>&1; then
        echo -e "${RED}[ERROR] Bash is not available.${RESET}"
        exit 1
    fi

    echo -e "${GREEN}[OK] Requirements look good.${RESET}"
    echo
}

locate_repo() {
    echo -e "${YELLOW}[2/6] Locating Ghost Engine repository...${RESET}"

    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        REPO_ROOT="$(git rev-parse --show-toplevel)"
        cd "$REPO_ROOT"

        echo -e "${GREEN}[OK] Using current repository:${RESET}"
        echo -e "    ${CYAN}${REPO_ROOT}${RESET}"

    elif [[ -d "$HOME/$REPO_NAME/.git" ]]; then
        REPO_ROOT="$HOME/$REPO_NAME"
        cd "$REPO_ROOT"

        echo -e "${GREEN}[OK] Found repository in home directory:${RESET}"
        echo -e "    ${CYAN}${REPO_ROOT}${RESET}"

    else
        echo -e "${RED}[ERROR] Ghost Engine repository not found.${RESET}"
        echo
        echo -e "${YELLOW}Clone it first with:${RESET}"
        echo -e "git clone ${REPO_URL}"
        exit 1
    fi

    echo
}

check_repo_files() {
    echo -e "${YELLOW}[3/6] Checking repository files...${RESET}"

    if [[ ! -f "$SCRIPT_NAME" ]]; then
        echo -e "${RED}[ERROR] Missing ${SCRIPT_NAME} in repo.${RESET}"
        exit 1
    fi

    if [[ ! -f "$INSTALL_SCRIPT" ]]; then
        echo -e "${RED}[ERROR] Missing ${INSTALL_SCRIPT} in repo.${RESET}"
        exit 1
    fi

    CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
    CURRENT_COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

    echo -e "${GREEN}[OK] Repository files verified.${RESET}"
    printf "%-18s %s\n" "Branch:" "$CURRENT_BRANCH"
    printf "%-18s %s\n" "Current Commit:" "$CURRENT_COMMIT"
    echo
}

warn_local_changes() {
    echo -e "${YELLOW}[4/6] Checking local changes...${RESET}"

    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo -e "${MAG}[WARNING] You have local uncommitted changes.${RESET}"
        echo -e "${YELLOW}Updating may cause merge conflicts or overwrite work.${RESET}"
        echo
        read -r -p "Continue anyway? Type 'yes' to continue: " ans

        if [[ "$ans" != "yes" ]]; then
            echo -e "${YELLOW}[CANCELLED] Update aborted by user.${RESET}"
            exit 0
        fi
    else
        echo -e "${GREEN}[OK] No local changes detected.${RESET}"
    fi

    echo
}

pull_updates() {
    echo -e "${YELLOW}[5/6] Pulling latest changes...${RESET}"

    git fetch origin

    if git rev-parse --verify "origin/$CURRENT_BRANCH" >/dev/null 2>&1; then
        git pull --rebase origin "$CURRENT_BRANCH"
    else
        git pull --rebase
    fi

    NEW_COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

    echo -e "${GREEN}[OK] Repository updated.${RESET}"
    printf "%-18s %s\n" "Old Commit:" "$CURRENT_COMMIT"
    printf "%-18s %s\n" "New Commit:" "$NEW_COMMIT"
    echo
}

reinstall_engine() {
    echo -e "${YELLOW}[6/6] Reinstalling Ghost Engine...${RESET}"
    echo

    chmod +x "$INSTALL_SCRIPT"

    # Fix Windows CRLF line endings if needed
    sed -i 's/\r$//' "$INSTALL_SCRIPT" 2>/dev/null || true
    sed -i 's/\r$//' "$SCRIPT_NAME" 2>/dev/null || true

    bash "$INSTALL_SCRIPT"

    echo
    echo -e "${GREEN}[OK] Installer completed.${RESET}"
    echo
}

show_summary() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}UPDATE COMPLETE${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    printf "%-18s %s\n" "Platform:" "$PLATFORM"
    printf "%-18s %s\n" "Repository:" "$REPO_ROOT"
    printf "%-18s %s\n" "Branch:" "$CURRENT_BRANCH"
    printf "%-18s %s\n" "Updated To:" "$NEW_COMMIT"

    echo
    echo -e "${GREEN}[SUCCESS] Ghost Engine is now updated to the latest build.${RESET}"
    echo -e "${CYAN}Run it with:${RESET} ${BOLD}ns-ghost${RESET}"
    echo
}

main() {
    detect_platform
    print_header
    check_requirements
    locate_repo
    check_repo_files
    warn_local_changes
    pull_updates
    reinstall_engine
    show_summary
}

main "$@"