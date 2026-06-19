#!/usr/bin/env bash
# NS GAMMING – GHOST ENGINE v4 Installer (Termux)

set -e

if command -v termux-info >/dev/null 2>&1; then
    PLATFORM="termux"
    BIN_DIR="/data/data/com.termux/files/usr/bin"

elif grep -qi microsoft /proc/version 2>/dev/null; then
    PLATFORM="wsl"
    BIN_DIR="$HOME/.local/bin"

elif [[ "$(uname)" == "Linux" ]]; then
    PLATFORM="linux"
    BIN_DIR="$HOME/.local/bin"

elif command -v brew >/dev/null 2>&1; then
    PLATFORM="mac"

    if [[ -d "/opt/homebrew/bin" ]]; then
        BIN_DIR="/opt/homebrew/bin"
    else
        BIN_DIR="/usr/local/bin"
    fi

else
    echo "Unsupported platform"
    exit 1
fi

INSTALL_NAME="ns-ghost"
SCRIPT_NAME="ns-ghost.sh"

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"
BOLD="\e[1m"

install_dependencies() {

    echo -e "${YELLOW}[+] Installing dependencies...${RESET}"

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

            echo -e "${YELLOW}[+] Checking sudo access...${RESET}"

            sudo -v || {
                echo -e "${RED}[ERROR] Sudo access required.${RESET}"
                exit 1
            }

            echo -e "${YELLOW}[+] Removing conflicting system services...${RESET}"

            sudo systemctl stop tor 2>/dev/null || true
            sudo systemctl stop privoxy 2>/dev/null || true

            sudo systemctl disable tor 2>/dev/null || true
            sudo systemctl disable privoxy 2>/dev/null || true

            sudo apt update

            sudo apt install -y \
                tor \
                privoxy \
                curl \
                netcat-openbsd

            echo -e "${YELLOW}[+] Verifying installation...${RESET}"

            command -v tor >/dev/null || {
                echo -e "${RED}[ERROR] TOR installation failed.${RESET}"
                exit 1
            }

            command -v privoxy >/dev/null || {
                echo -e "${RED}[ERROR] Privoxy installation failed.${RESET}"
                exit 1
            }

            command -v curl >/dev/null || {
                echo -e "${RED}[ERROR] Curl installation failed.${RESET}"
                exit 1
            }

            echo -e "${GREEN}[SUCCESS] Dependencies installed.${RESET}"

        ;;

        mac)

            brew install \
                tor \
                privoxy \
                curl \
                netcat

        ;;

        *)

            echo -e "${RED}[ERROR] Unsupported platform.${RESET}"
            exit 1

        ;;

    esac

}

echo -e "${CYAN}${BOLD}┌──────────────────────────────────────────┐${RESET}"
echo -e "${CYAN}${BOLD}│  NS GAMMING – GHOST ENGINE Installer   │${RESET}"
echo -e "${CYAN}${BOLD}└──────────────────────────────────────────┘${RESET}"
echo

echo -e "${CYAN}[+] Platform detected:${RESET} $PLATFORM"

# 2) Check main script is present
if [[ ! -f "$SCRIPT_NAME" ]]; then
  echo -e "${RED}[!] Cannot find ${SCRIPT_NAME} in current directory.${RESET}"
  echo -e "${YELLOW}    Make sure you are inside the cloned repo folder:${RESET}"
  echo -e "    git clone https://github.com/ns-gamming/Termux-Tor-IP-Rotator"
  echo -e "    cd Termux-Tor-IP-Rotator"
  exit 1
fi

# 3) Make main script executable
chmod +x "$SCRIPT_NAME"

# 4) Install into Termux bin
mkdir -p "$BIN_DIR"
cp "$SCRIPT_NAME" "$BIN_DIR/$INSTALL_NAME"
chmod +x "$BIN_DIR/$INSTALL_NAME"
if [[ "$PLATFORM" == "linux" ]]; then

    mkdir -p "$HOME/.local/bin"

    if ! grep -q '.local/bin' "$HOME/.bashrc" 2>/dev/null; then
        echo '' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi

fi
install_dependencies

echo
echo -e "${GREEN}[+] Installation complete!${RESET}"
echo -e "${CYAN}You can now run Ghost Engine with:${RESET}"
echo -e "  ${BOLD}ns-ghost${RESET}"
echo
echo -e "${YELLOW}Tip:${RESET} Open a ${RED}${BOLD}NEW TERMINAL SESSION${RESET} and run:"
echo -e "  ${BOLD}${INSTALL_NAME}${RESET}"

if [[ "$PLATFORM" == "linux" ]]; then
    source "$HOME/.bashrc" 2>/dev/null || true
fi