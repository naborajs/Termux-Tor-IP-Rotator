#!/data/data/com.termux/files/usr/bin/bash
# NS GAMMING – GHOST ENGINE v4 Updater (Termux)

set -e

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"
BOLD="\e[1m"

echo -e "${CYAN}${BOLD}┌────────────────────────────────────┐${RESET}"
echo -e "${CYAN}${BOLD}│  NS GHOST ENGINE – Updater v1    │${RESET}"
echo -e "${CYAN}${BOLD}└────────────────────────────────────┘${RESET}"
echo

# Check if inside git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo -e "${RED}[!] You are not inside a git repository.${RESET}"
  echo -e "${YELLOW}    cd into your cloned Termux-Tor-IP-Rotator folder first.${RESET}"
  exit 1
fi

echo -e "${YELLOW}[+] Pulling latest changes from origin...${RESET}"
git pull --rebase

if [[ ! -f "ns-ghost.sh" ]]; then
  echo -e "${RED}[!] Updated repo does not contain ns-ghost.sh${RESET}"
  exit 1
fi

if [[ ! -f "install.sh" ]]; then
  echo -e "${RED}[!] install.sh not found. Cannot reinstall binary.${RESET}"
  exit 1
fi

echo
echo -e "${YELLOW}[+] Re-running installer to update binary...${RESET}"
bash install.sh

echo
echo -e "${GREEN}[+] Update complete!${RESET}"
echo -e "${CYAN}You are now running the latest NS GHOST ENGINE build.${RESET}"
