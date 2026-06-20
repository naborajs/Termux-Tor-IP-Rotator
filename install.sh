#!/usr/bin/env bash
# NS GAMMING – GHOST ENGINE v5 Installer

set -e

INSTALL_NAME="ns-ghost"
SCRIPT_NAME="ns-ghost.sh"
INSTALL_SCRIPT="install.sh"
UPDATE_SCRIPT="update.sh"
UNINSTALL_SCRIPT="uninstall.sh"
REPO_URL="https://github.com/naborajs/Termux-Tor-IP-Rotator.git"
REPO_NAME="Termux-Tor-IP-Rotator"

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
MAG="\e[35m"
BLUE="\e[34m"
RESET="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"

PLATFORM="unknown"
PLATFORM_NAME="Unknown"
BIN_DIR=""
SHELL_RC=""
SUDO_AVAILABLE=false

print_header() {

    clear

    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║            NABORAJ – GHOST ENGINE INSTALLER           ║${RESET}"
    echo -e "${CYAN}${BOLD}║                         Version v5                       ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo
}

detect_platform() {

    if command -v termux-info >/dev/null 2>&1; then
        PLATFORM="termux"
        PLATFORM_NAME="📱 Termux"
        BIN_DIR="/data/data/com.termux/files/usr/bin"

    elif grep -qi microsoft /proc/version 2>/dev/null; then
        PLATFORM="wsl"
        PLATFORM_NAME="🖥 WSL"
        BIN_DIR="$HOME/.local/bin"

    elif [[ "$(uname)" == "Linux" ]]; then
        PLATFORM="linux"
        PLATFORM_NAME="🐧 Linux"
        BIN_DIR="$HOME/.local/bin"

    elif [[ "$(uname)" == "Darwin" ]]; then
        PLATFORM="macos"
        PLATFORM_NAME="🍎 macOS"

        if [[ -d "/opt/homebrew/bin" ]]; then
            BIN_DIR="/opt/homebrew/bin"
        else
            BIN_DIR="/usr/local/bin"
        fi

    else
        echo -e "${RED}[ERROR] Unsupported platform.${RESET}"
        exit 1
    fi

    if [[ -n "${ZSH_VERSION:-}" ]]; then
        SHELL_RC="$HOME/.zshrc"
    else
        SHELL_RC="$HOME/.bashrc"
    fi
}

show_environment_info() {

    echo -e "${CYAN}Detected Platform:${RESET} ${PLATFORM_NAME}"
    echo -e "${CYAN}Install Path:${RESET} ${BIN_DIR}"
    echo -e "${CYAN}Repository:${RESET} ${REPO_URL}"
    echo
}

check_repo_files() {

    echo -e "${YELLOW}[1/9] Checking repository files...${RESET}"

    if [[ ! -f "$SCRIPT_NAME" ]]; then
        echo -e "${RED}[ERROR] Cannot find ${SCRIPT_NAME} in the current directory.${RESET}"
        echo
        echo -e "${YELLOW}Make sure you are inside the Ghost Engine repo folder.${RESET}"
        echo -e "Clone it using:"
        echo -e "  git clone ${REPO_URL}"
        echo -e "  cd Termux-Tor-IP-Rotator"
        exit 1
    fi

    echo -e "${GREEN}[OK] Main script found.${RESET}"
    echo
}

prepare_shell_scripts() {

    echo -e "${YELLOW}[2/9] Preparing Ghost Engine shell scripts...${RESET}"

    local scripts=(
        "$SCRIPT_NAME"
        "$INSTALL_SCRIPT"
        "$UPDATE_SCRIPT"
        "$UNINSTALL_SCRIPT"
    )

    local script

    for script in "${scripts[@]}"; do

        if [[ -f "$script" ]]; then

            sed -i 's/\r$//' "$script" 2>/dev/null || true

            if chmod +x "$script" 2>/dev/null; then
                echo -e "${GREEN}[OK]${RESET} Prepared ${script}"
            else
                echo -e "${YELLOW}[WARN]${RESET} Could not mark ${script} executable"
            fi

        else
            echo -e "${YELLOW}[SKIP]${RESET} ${script} not found"
        fi

    done

    echo
}

check_sudo_if_needed() {

    if [[ "$PLATFORM" == "linux" || "$PLATFORM" == "wsl" ]]; then
        echo -e "${YELLOW}[3/9] Checking sudo access...${RESET}"

        if sudo -v >/dev/null 2>&1; then
            SUDO_AVAILABLE=true
            echo -e "${GREEN}[OK] Sudo access confirmed.${RESET}"
        else
            echo -e "${RED}[ERROR] Sudo access is required on Linux/WSL.${RESET}"
            exit 1
        fi

        echo
    fi
}

disable_conflicting_services() {

    echo -e "${YELLOW}[4/9] Checking for conflicting Tor / Privoxy services...${RESET}"

    case "$PLATFORM" in

        linux|wsl)

            echo -e "${DIM}Stopping system services that may hijack ports 9050 / 9051 / 8118...${RESET}"

            sudo systemctl stop tor 2>/dev/null || true
            sudo systemctl stop privoxy 2>/dev/null || true

            sudo systemctl disable tor 2>/dev/null || true
            sudo systemctl disable privoxy 2>/dev/null || true

            sudo systemctl stop tor@default 2>/dev/null || true
            sudo systemctl disable tor@default 2>/dev/null || true

            pkill tor 2>/dev/null || true
            pkill privoxy 2>/dev/null || true

            echo -e "${GREEN}[OK] Conflicting Tor / Privoxy services handled.${RESET}"
        ;;

        *)
            echo -e "${YELLOW}[SKIP] No system service cleanup needed on this platform.${RESET}"
        ;;

    esac

    echo
}

install_dependencies() {

    echo -e "${YELLOW}[4/8] Installing dependencies...${RESET}"

    case "$PLATFORM" in

        termux)

            pkg update -y

            pkg install -y \
                tor \
                privoxy \
                curl \
                netcat-openbsd

        ;;

        linux|wsl)

            sudo apt update

            sudo apt install -y \
                tor \
                privoxy \
                curl \
                netcat-openbsd

        ;;

        macos)

            if ! command -v brew >/dev/null 2>&1; then
                echo -e "${RED}[ERROR] Homebrew is required on macOS.${RESET}"
                echo -e "${YELLOW}Install Homebrew first: https://brew.sh/${RESET}"
                exit 1
            fi

            brew install \
                tor \
                privoxy \
                curl \
                netcat || true

        ;;

    esac

    echo -e "${GREEN}[OK] Dependency installation step complete.${RESET}"
    echo
}

verify_dependencies() {

    echo -e "${YELLOW}[6/9] Verifying installed dependencies...${RESET}"

    local fail=0

    for cmd in tor privoxy curl; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${GREEN}[OK]${RESET} $cmd → $(command -v "$cmd")"
        else
            echo -e "${RED}[MISSING]${RESET} $cmd"
            fail=1
        fi
    done

    if command -v nc >/dev/null 2>&1 || command -v netcat >/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${RESET} netcat available"
    else
        echo -e "${RED}[MISSING]${RESET} netcat / nc"
        fail=1
    fi

    echo

    if (( fail != 0 )); then
        echo -e "${RED}[ERROR] Some dependencies are missing. Installation cannot continue.${RESET}"
        exit 1
    fi

    echo -e "${GREEN}[OK] All required dependencies are installed.${RESET}"
    echo
}

install_binary() {

    echo -e "${YELLOW}[7/9] Installing Ghost Engine binary...${RESET}"

    mkdir -p "$BIN_DIR"
    cp "$SCRIPT_NAME" "$BIN_DIR/$INSTALL_NAME"
    chmod +x "$BIN_DIR/$INSTALL_NAME"

    echo -e "${GREEN}[OK] Installed:${RESET} $BIN_DIR/$INSTALL_NAME"
    echo
}

ensure_path() {

    echo -e "${YELLOW}[8/9] Checking PATH configuration...${RESET}"

    case "$PLATFORM" in

        linux|wsl)

            mkdir -p "$HOME/.local/bin"

            if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then

                if [[ -n "$SHELL_RC" ]]; then
                    touch "$SHELL_RC"

                    if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC" 2>/dev/null; then
                        {
                            echo
                            echo '# Ghost Engine installer PATH entry'
                            echo 'export PATH="$HOME/.local/bin:$PATH"'
                        } >> "$SHELL_RC"
                    fi

                    echo -e "${GREEN}[OK] Added ~/.local/bin to PATH in ${SHELL_RC}.${RESET}"
                else
                    echo -e "${YELLOW}[WARN] Could not detect shell rc file. Add this manually:${RESET}"
                    echo 'export PATH="$HOME/.local/bin:$PATH"'
                fi

            else
                echo -e "${GREEN}[OK] ~/.local/bin already exists in PATH.${RESET}"
            fi

        ;;

        *)
            echo -e "${YELLOW}[SKIP] PATH update not required for this platform.${RESET}"
        ;;

    esac

    echo
}

show_post_install_guide() {

    echo -e "${YELLOW}[9/9] Final setup guide${RESET}"
    echo

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}GHOST ENGINE INSTALLED SUCCESSFULLY${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    printf "%-18s %s\n" "Platform:" "$PLATFORM_NAME"
    printf "%-18s %s\n" "Binary:" "$BIN_DIR/$INSTALL_NAME"
    printf "%-18s %s\n" "Command:" "ns-ghost"

    echo

    case "$PLATFORM" in

        wsl)

            echo -e "${YELLOW}WSL Notes:${RESET}"
            echo -e "• This installer disabled Ubuntu's default Tor / Privoxy services to prevent port conflicts."
            echo -e "• Ghost Engine will use its own Tor + Privoxy instance instead."
            echo -e "• When Ghost Engine starts, it will show the Windows proxy address to use."
            echo -e "• If Windows internet stops after enabling the proxy, make sure you use the proxy address shown by Ghost Engine startup, not an old one."
            echo
        ;;

        linux)

            echo -e "${YELLOW}Linux Notes:${RESET}"
            echo -e "• System Tor / Privoxy services were disabled to avoid conflicts."
            echo -e "• Ghost Engine will run its own isolated Tor + Privoxy setup."
            echo
        ;;

        termux)

            echo -e "${YELLOW}Termux Notes:${RESET}"
            echo -e "• Ghost Engine uses local Tor + Privoxy inside Termux."
            echo -e "• Some Android apps may not respect proxy settings unless configured manually."
            echo
        ;;

        macos)

            echo -e "${YELLOW}macOS Notes:${RESET}"
            echo -e "• If Homebrew installed Tor / Privoxy successfully, Ghost Engine is ready to use."
            echo
        ;;

    esac

    echo -e "${CYAN}Run Ghost Engine with:${RESET}"
    echo -e "  ${BOLD}ns-ghost${RESET}"
    echo

    if [[ "$PLATFORM" == "linux" || "$PLATFORM" == "wsl" ]]; then
        echo -e "${YELLOW}If 'ns-ghost' is not found immediately:${RESET}"
        echo -e "Open a new terminal or run:"
        echo -e "  source ${SHELL_RC}"
        echo
    fi
}

main() {

    print_header
    detect_platform
    show_environment_info
    check_repo_files
    prepare_shell_scripts
    check_sudo_if_needed
    disable_conflicting_services
    install_dependencies
    verify_dependencies
    install_binary
    ensure_path
    show_post_install_guide
}

main "$@"