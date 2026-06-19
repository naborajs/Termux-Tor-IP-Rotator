#!/data/data/com.termux/files/usr/bin/bash
# NS GAMMING – GHOST ENGINE v4 Uninstaller (Termux)

set -e

PREFIX="/data/data/com.termux/files/usr"
BIN_DIR="$PREFIX/bin"
INSTALL_NAME="ns-ghost"
BASE_DIR="$HOME/.ns_ghost"

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"
BOLD="\e[1m"

echo -e "${CYAN}${BOLD}┌──────────────────────────────────────────┐${RESET}"
echo -e "${CYAN}${BOLD}│  NS GAMMING – GHOST ENGINE Uninstaller │${RESET}"
echo -e "${CYAN}${BOLD}└──────────────────────────────────────────┘${RESET}"
echo

if [[ ! -d "$PREFIX" ]]; then
  echo -e "${RED}[!] This uninstaller is for Termux only.${RESET}"
  exit 1
fi

# Remove binary
if [[ -f "$BIN_DIR/$INSTALL_NAME" ]]; then
  rm -f "$BIN_DIR/$INSTALL_NAME"
  echo -e "${GREEN}[+] Removed binary:${RESET} $BIN_DIR/$INSTALL_NAME"
else
  echo -e "${YELLOW}[i] No binary found at:${RESET} $BIN_DIR/$INSTALL_NAME"
fi

# Ask about config
if [[ -d "$BASE_DIR" ]]; then
  echo
  echo -e "${YELLOW}[?] Do you also want to remove config/log directory?${RESET}"
  echo -e "    ${CYAN}$BASE_DIR${RESET}"
  read -p "    Type 'yes' to delete, anything else to keep: " ans
  if [[ "$ans" == "yes" ]]; then
    rm -rf "$BASE_DIR"
    echo -e "${GREEN}[+] Removed:${RESET} $BASE_DIR"
  else
    echo -e "${YELLOW}[i] Keeping:${RESET} $BASE_DIR"
  fi
fi

echo
echo -e "${GREEN}[+] Uninstall complete.${RESET}"
