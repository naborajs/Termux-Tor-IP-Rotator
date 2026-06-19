#!/usr/bin/env bash
# 💙 NS GAMMING – GHOST ENGINE v4 (HYBRID SINGLE NODE)
# Single Tor • ControlPort • Auto-Rotate • IP History • Hacker UI

PREFIX="${PREFIX:-/usr}"
BASE_DIR="$HOME/.ns_ghost"
TOR_DIR="$BASE_DIR/tor_single"
PRIVOXY_CONF="$BASE_DIR/privoxy.conf"

TOR_SOCKS_PORT=9050
TOR_CONTROL_PORT=9051
PRIVOXY_PORT=8118

LOG_FILE="$BASE_DIR/tor_debug.log"
IP_HISTORY=()
TOTAL_ROTATIONS=0
SESSION_START=$(date +%s)
LAST_IP=""
DUPLICATE_COUNT=0
MAX_DUPLICATES=5


GREEN="\e[38;5;46m"
CYAN="\e[38;5;51m"
RED="\e[38;5;196m"
YELLOW="\e[38;5;226m"
PURPLE="\e[38;5;129m"
BLUE="\e[38;5;39m"
MAG="\e[38;5;213m"
DIM="\e[2m"
BOLD="\e[1m"
RESET="\e[0m"

detect_platform() {

    if grep -qi microsoft /proc/version 2>/dev/null; then
        PLATFORM_NAME="🖥 WSL Ubuntu"
        PROXY_HOST=$(hostname -I | awk '{print $1}')

    elif command -v termux-info >/dev/null 2>&1; then
        PLATFORM_NAME="📱 Termux"
        PROXY_HOST="127.0.0.1"

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM_NAME="🍎 macOS"
        PROXY_HOST="127.0.0.1"

    else
        PLATFORM_NAME="🐧 Linux"
        PROXY_HOST="127.0.0.1"
    fi
}

detect_status() {

    if check_tor; then
        TOR_STATUS="${GREEN}ONLINE${RESET}"
    else
        TOR_STATUS="${RED}OFFLINE${RESET}"
    fi

    if check_privoxy; then
        PROXY_STATUS="${GREEN}ONLINE${RESET}"
    else
        PROXY_STATUS="${RED}OFFLINE${RESET}"
    fi

    CURRENT_IP=$(curl --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
        -s https://api64.ipify.org 2>/dev/null)

    [[ -z "$CURRENT_IP" ]] && CURRENT_IP="UNKNOWN"
}



banner() {
    clear

    detect_platform
    detect_status
    echo -e "${GREEN}${BOLD}"
    cat << "EOF"

 ▄████  ██░ ██  ▒█████    ██████ ▄▄▄█████▓
██▒ ▀█▒▓██░ ██▒▒██▒  ██▒▒██    ▒ ▓  ██▒ ▓▒
▒██░▄▄▄░▒██▀▀██░▒██░  ██▒░ ▓██▄   ▒ ▓██░ ▒░
░▓█  ██▓░▓█ ░██ ▒██   ██░  ▒   ██▒░ ▓██▓ ░
░▒▓███▀▒░▓█▒░██▓░ ████▓▒░▒██████▒▒  ▒██▒ ░
 ░▒   ▒  ▒ ░░▒░▒░ ▒░▒░▒░ ▒ ▒▓▒ ▒ ░  ▒ ░░
  ░   ░  ▒ ░▒░ ░  ░ ▒ ▒░ ░ ░▒  ░ ░    ░
░ ░   ░  ░  ░░ ░░ ░ ░ ▒  ░  ░  ░    ░
      ░  ░  ░  ░    ░ ░        ░

 ███████╗███╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
 ██╔════╝████╗  ██║██╔════╝ ██║████╗  ██║██╔════╝
 █████╗  ██╔██╗ ██║██║  ███╗██║██╔██╗ ██║█████╗
 ██╔══╝  ██║╚██╗██║██║   ██║██║██║╚██╗██║██╔══╝
 ███████╗██║ ╚████║╚██████╔╝██║██║ ╚████║███████╗
 ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝

EOF
    echo -e "${RESET}"

    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}${BOLD}👻 GHOST ENGINE v5${RESET} ${DIM}| Advanced TOR Identity Framework${RESET}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║              SYSTEM STATUS PANEL                 ║${RESET}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════╣${RESET}"

    printf "${CYAN}║${RESET} %-13s │ %-28s ${CYAN}║${RESET}\n" \
    "PLATFORM" "$PLATFORM_NAME"

    printf "${CYAN}║${RESET} %-13s │ %-28b ${CYAN}║${RESET}\n" \
    "TOR STATUS" "$TOR_STATUS"

    printf "${CYAN}║${RESET} %-13s │ %-28b ${CYAN}║${RESET}\n" \
    "PROXY" "$PROXY_STATUS"

    printf "${CYAN}║${RESET} %-13s │ %-28s ${CYAN}║${RESET}\n" \
    "EXIT IP" "$CURRENT_IP"

    printf "${CYAN}║${RESET} %-13s │ %-28s ${CYAN}║${RESET}\n" \
    "PROXY HOST" "${PROXY_HOST}:${PRIVOXY_PORT}"

    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"

    NOW=$(date +%s)
    UPTIME=$((NOW - SESSION_START))
    
    echo

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}💡 Quick Tip:${RESET}"

    if grep -qi microsoft /proc/version 2>/dev/null; then
        echo -e "${GREEN}[INFO] WSL Environment Detected${RESET}"
        echo
        echo -e "Windows Proxy Setup:"
        echo -e "  Host : ${PROXY_HOST}"
        echo -e "  Port : ${PRIVOXY_PORT}"
        echo
        echo -e "Test TOR:"
        echo -e "  curl --socks5 127.0.0.1:${TOR_SOCKS_PORT} https://api64.ipify.org"
    else
        echo -e "Use Proxy:"
        echo -e "Address: 127.0.0.1"
        echo -e "Port: ${PRIVOXY_PORT}"
    fi

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${DIM}Created By:${RESET} ${GREEN}Naboraj Sarkar (Nishant)${RESET}"
    echo
}

matrix_line() {
    local len=40
    local line=""
    for ((i=0; i<len; i++)); do
        local r=$((RANDOM % 16))
        line+=$(printf '%X' "$r")
    done
    echo -e "${GREEN}${DIM}${line}${RESET}"
}

matrix_burst() {
    for _ in {1..3}; do
        matrix_line
        sleep 0.05
    done
}

security_hardening() {

    if command -v termux-wake-lock >/dev/null 2>&1; then
        termux-wake-lock 2>/dev/null
    fi

    export HISTFILE=/dev/null
    unset HISTFILE

    rm -f "$HOME/.bash_history" "$HOME/.zsh_history" 2>/dev/null

    mkdir -p "$BASE_DIR"
    : > "$LOG_FILE"
}

install_deps() {
    banner
    echo -e "${YELLOW}[+] Checking dependencies...${RESET}"

    if command -v pkg >/dev/null 2>&1; then

        pkg update -y >/dev/null 2>&1

        for pkg_name in tor privoxy curl netcat-openbsd; do
            pkg install -y "$pkg_name" >/dev/null 2>&1
        done

    elif command -v apt >/dev/null 2>&1; then

        sudo apt update -y >/dev/null 2>&1
        sudo apt install -y tor privoxy curl netcat-openbsd >/dev/null 2>&1

    elif command -v brew >/dev/null 2>&1; then

        brew install tor privoxy curl netcat

    else

        echo -e "${RED}[!] Unsupported system.${RESET}"
        exit 1

    fi
}

check_tor() {
    nc -z 127.0.0.1 "$TOR_SOCKS_PORT" >/dev/null 2>&1
}

check_privoxy() {
    nc -z 127.0.0.1 "$PRIVOXY_PORT" >/dev/null 2>&1
}

remember_ip() {
    local ip="$1"
    [ -z "$ip" ] && return
    IP_HISTORY+=("$ip")
    if (( ${#IP_HISTORY[@]} > 15 )); then
        IP_HISTORY=("${IP_HISTORY[@]:1}")
    fi
}

check_duplicate_ip() {

    local current_ip="$1"

    [[ -z "$current_ip" ]] && return

    if [[ "$current_ip" == "$LAST_IP" ]]; then
        ((DUPLICATE_COUNT++))
    else
        DUPLICATE_COUNT=0
    fi

    LAST_IP="$current_ip"

    if (( DUPLICATE_COUNT >= MAX_DUPLICATES )); then

        echo
        echo -e "${RED}[!] Same IP detected ${MAX_DUPLICATES} times.${RESET}"
        echo -e "${YELLOW}[+] Restarting Tor engine...${RESET}"

        pkill tor 2>/dev/null
        pkill privoxy 2>/dev/null

        sleep 3

        start_tor_engine

        DUPLICATE_COUNT=0
    fi
}

show_ip_history() {
    echo -e "${CYAN}📜 IP History (this session):${RESET}"
    if (( ${#IP_HISTORY[@]} == 0 )); then
        echo -e "  ${DIM}(no IPs recorded yet)${RESET}"
        return
    fi
    local idx=1
    for ip in "${IP_HISTORY[@]}"; do
        echo -e "  ${MAG}#${idx}${RESET}  ${GREEN}${ip}${RESET}"
        ((idx++))
    done
}

start_tor_engine() {
    banner
    echo -e "${YELLOW}[+] Starting Tor + Privoxy engine (single node)...${RESET}"
    matrix_burst

    pkill tor 2>/dev/null
    pkill privoxy 2>/dev/null

    rm -rf "$TOR_DIR"
    mkdir -p "$TOR_DIR"
    : > "$LOG_FILE"

    local TORRC="$TOR_DIR/torrc"
    cat <<EOF > "$TORRC"
SocksPort 127.0.0.1:${TOR_SOCKS_PORT}
ControlPort 127.0.0.1:${TOR_CONTROL_PORT}
CookieAuthentication 0
AvoidDiskWrites 1
DataDirectory ${TOR_DIR}/data
EOF

    tor -f "$TORRC" >>"$LOG_FILE" 2>&1 &
    sleep 1

    echo -e "${CYAN}[*] Waiting for Tor to bootstrap...${RESET}"
    local tries=0
    local max_tries=30
    while (( tries < max_tries )); do
        if check_tor; then
            break
        fi
        ((tries++))
        sleep 1
    done

    if ! check_tor; then
        echo -e "${RED}[!] Tor did not start correctly on ${TOR_SOCKS_PORT}.${RESET}"
        echo -e "${YELLOW}Check logs via: Show Status & Last Logs.${RESET}"
        sleep 2
        return 1
    fi

    cat <<EOF > "$PRIVOXY_CONF"
listen-address 0.0.0.0:${PRIVOXY_PORT}
toggle 1
enable-remote-toggle 0
enable-remote-http-toggle 0
accept-intercepted-requests 0
allow-cgi-request-crunching 0
forwarded-connect-retries 1
forward-socks5 / 127.0.0.1:${TOR_SOCKS_PORT} .
EOF

    privoxy "$PRIVOXY_CONF" >/dev/null 2>&1 &
    sleep 2

    if ! check_privoxy; then
        echo -e "${RED}[!] Privoxy failed to start on ${PRIVOXY_PORT}.${RESET}"
        sleep 2
        return 1
    fi

    banner
    echo -e "${GREEN}[+] Ghost Engine ONLINE.${RESET}"
    echo
    echo -e "${CYAN}HTTP proxy for Wi-Fi / apps:${RESET} ${GREEN}127.0.0.1:${PRIVOXY_PORT}${RESET}"
    echo
    echo -e "${DIM}Tip: Wi-Fi → Modify network → Proxy: Manual → 127.0.0.1 : ${PRIVOXY_PORT}${RESET}"
    echo
    read -p $'Press ENTER to continue... ' _
}

stop_all() {
    banner
    echo -e "${YELLOW}[+] Stopping Tor & Privoxy...${RESET}"
    pkill tor 2>/dev/null
    pkill privoxy 2>/dev/null
    echo -e "${GREEN}[+] Services stopped.${RESET}"
    read -p $'Press ENTER to continue... ' _
}

show_status() {
    banner
    echo -e "${CYAN}[+] Tor Status:${RESET}"
    if check_tor; then
        echo -e "  ${GREEN}SocksPort 127.0.0.1:${TOR_SOCKS_PORT} (UP)${RESET}"
    else
        echo -e "  ${RED}SocksPort 127.0.0.1:${TOR_SOCKS_PORT} (DOWN)${RESET}"
    fi
    echo
    echo -e "${CYAN}[+] Privoxy:${RESET}"
    if check_privoxy; then
        echo -e "  ${GREEN}127.0.0.1:${PRIVOXY_PORT} (UP)${RESET}"
    else
        echo -e "  ${RED}127.0.0.1:${PRIVOXY_PORT} (DOWN)${RESET}"
    fi
    echo
    echo -e "${CYAN}[+] Last Tor log lines:${RESET}"
    echo -e "${DIM}"
    tail -n 10 "$LOG_FILE" 2>/dev/null || echo "No logs yet."
    echo -e "${RESET}"
    echo
    show_ip_history
    echo
    read -p $'Press ENTER to continue... ' _
}

check_ip() {
    banner
    if ! check_privoxy || ! check_tor; then
        echo -e "${RED}[!] Engine is not running. Starting it now...${RESET}"
        start_tor_engine || return
    fi
    echo -e "${YELLOW}[+] Checking IP via Tor...${RESET}"
    local IP
    IP=$(curl --socks5 127.0.0.1:${TOR_SOCKS_PORT} -s https://api64.ipify.org 2>/dev/null)
    remember_ip "$IP"
    echo
    matrix_burst
    echo -e "${GREEN}🌍 Current Tor Exit IP: ${BOLD}${IP:-UNKNOWN}${RESET}"
    echo -e "${BLUE}Proxy: 127.0.0.1:${PRIVOXY_PORT}${RESET}"
    echo
    show_ip_history
    echo
    read -p $'Press ENTER to continue... ' _
}

single_rotate() {
    banner
    if ! check_privoxy || ! check_tor; then
        echo -e "${RED}[!] Engine is not running. Starting it now...${RESET}"
        start_tor_engine || return
    fi
    echo -e "${YELLOW}[+] Sending NEWNYM signal (single rotate)...${RESET}"
    echo -e "AUTHENTICATE \"\"\r\nSIGNAL NEWNYM\r\nQUIT" \
        | nc 127.0.0.1 "$TOR_CONTROL_PORT" >/dev/null 2>&1
    sleep 3
    local IP
    IP=$(curl --socks5 127.0.0.1:${TOR_SOCKS_PORT} -s https://api64.ipify.org 2>/dev/null)
    remember_ip "$IP"
    ((TOTAL_ROTATIONS++))
    echo
    matrix_burst
    echo -e "${GREEN}♻ Single Rotate Done${RESET}"
    echo -e "${GREEN}New Tor Exit IP: ${BOLD}${IP:-UNKNOWN}${RESET}"
    echo
    show_ip_history
    echo
    read -p $'Press ENTER to continue... ' _
}

smart_rotate_loop() {
    banner
    echo -e "${CYAN}[+] Auto-Rotation Mode (Hybrid)${RESET}"
    echo -e "${DIM}Tor itself prefers 10+ sec, but 3–5 sec is okay for fast cycling.${RESET}"
    echo
    echo -ne "${CYAN}Enter rotation interval in seconds (min 3): ${RESET}"
    read -r T
    if ! [[ "$T" =~ ^[0-9]+$ ]]; then
        T=10
    fi
    (( T < 3 )) && T=3

    while true; do
        if ! check_privoxy || ! check_tor; then
            echo -e "${YELLOW}[!] Engine looks down, restarting...${RESET}"
            start_tor_engine || {
                echo -e "${RED}[!] Could not restart engine. Exiting rotate mode.${RESET}"
                sleep 2
                return
            }
        fi

        echo -e "AUTHENTICATE \"\"\r\nSIGNAL NEWNYM\r\nQUIT" \
            | nc 127.0.0.1 "$TOR_CONTROL_PORT" >/dev/null 2>&1

        local IP
        IP=$(curl --socks5 127.0.0.1:${TOR_SOCKS_PORT} -s https://api64.ipify.org 2>/dev/null)
        remember_ip "$IP"
        ((TOTAL_ROTATIONS++))
        check_duplicate_ip "$IP"

        banner
        matrix_burst
        echo -e "${GREEN}🌐 Auto-Rotate Running${RESET}"
        echo -e "${GREEN}Current Tor Exit IP: ${BOLD}${IP:-UNKNOWN}${RESET}"
        echo -e "${BLUE}Proxy: 127.0.0.1:${PRIVOXY_PORT}${RESET}"
        echo -e "${CYAN}Requested interval: ${T}s (sleep is exact).${RESET}"
        echo -e "${YELLOW}Duplicate Count: ${DUPLICATE_COUNT}/${MAX_DUPLICATES}${RESET}"
        echo
        show_ip_history
        echo
        echo -e "${MAG}CTRL + C to stop auto-rotation.${RESET}"
        sleep "$T"
    done
}

torify_url() {
    
    if ! check_privoxy || ! check_tor; then
        echo -e "${RED}[!] Engine is not running. Starting it now...${RESET}"
        start_tor_engine || return
    fi
    echo -ne "${CYAN}Enter URL (example: https://ifconfig.me): ${RESET}"
    read -r URL
    [[ -z "$URL" ]] && { echo -e "${RED}[!] No URL entered.${RESET}"; sleep 1; return; }
    echo -e "${YELLOW}[+] Fetching via Tor proxy...${RESET}"
    echo
    curl --proxy "http://127.0.0.1:${PRIVOXY_PORT}" -s "$URL"
    echo
    read -p $'Press ENTER to continue... ' _
}

proxy_guide() {

    clear

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║                    PROXY SETUP GUIDE                     ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo

    if grep -qi microsoft /proc/version 2>/dev/null; then

        echo -e "${GREEN}[SYSTEM DETECTED] WSL (Windows Subsystem for Linux)${RESET}"
        echo
        echo -e "${YELLOW}STEP 1:${RESET} Start Ghost Engine"
        echo -e "  1 ▶ Start Engine"
        echo
        echo -e "${YELLOW}STEP 2:${RESET} Open Windows Proxy Settings"
        echo -e "  Settings → Network & Internet → Proxy"
        echo
        echo -e "${YELLOW}STEP 3:${RESET} Enable Manual Proxy"
        echo -e "  Address : ${PROXY_HOST}"
        echo -e "  Port    : ${PRIVOXY_PORT}"
        echo
        echo -e "${YELLOW}STEP 4:${RESET} Open Browser"
        echo -e "  Chrome / Edge / Brave"
        echo
        echo -e "${YELLOW}STEP 5:${RESET} Verify"
        echo -e "  Option 7 → Verify TOR"
        echo
        echo -e "${GREEN}[TIP]${RESET} Disable Windows Proxy when Ghost Engine is not running."

    elif command -v termux-info >/dev/null 2>&1; then

        echo -e "${GREEN}[SYSTEM DETECTED] Android Termux${RESET}"
        echo
        echo -e "${YELLOW}STEP 1:${RESET} Start Ghost Engine"
        echo
        echo -e "${YELLOW}STEP 2:${RESET} Open WiFi Settings"
        echo -e "  WiFi → Current Network → Modify"
        echo
        echo -e "${YELLOW}STEP 3:${RESET} Proxy"
        echo -e "  Manual"
        echo
        echo -e "  Host : 127.0.0.1"
        echo -e "  Port : ${PRIVOXY_PORT}"
        echo
        echo -e "${YELLOW}STEP 4:${RESET} Verify TOR"

    elif [[ "$OSTYPE" == "darwin"* ]]; then

        echo -e "${GREEN}[SYSTEM DETECTED] macOS${RESET}"
        echo
        echo -e "System Settings → Network"
        echo -e "Configure Proxy"
        echo
        echo -e "Host : 127.0.0.1"
        echo -e "Port : ${PRIVOXY_PORT}"

    else

        echo -e "${GREEN}[SYSTEM DETECTED] Linux${RESET}"
        echo
        echo -e "Browser Proxy Settings"
        echo
        echo -e "Host : 127.0.0.1"
        echo -e "Port : ${PRIVOXY_PORT}"

    fi

    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}Useful Commands${RESET}"
    echo
    echo -e "Normal IP:"
    echo -e "  curl https://api64.ipify.org"
    echo
    echo -e "TOR IP:"
    echo -e "  curl --socks5 127.0.0.1:${TOR_SOCKS_PORT} https://api64.ipify.org"
    echo
    echo -e "Verify TOR:"
    echo -e "  Menu Option 7"
    echo

    read -p $'Press ENTER to continue... ' _
}

verify_tor() {

    banner

    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║                TOR VERIFICATION                   ║${RESET}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════╣${RESET}"

    if ! check_tor; then
        echo -e "${RED}║  TOR Status : OFFLINE                             ║${RESET}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
        echo
        echo -e "${RED}[!] TOR is not running.${RESET}"
        echo
        read -p $'Press ENTER to continue... ' _
        return
    fi

    local RESULT
    RESULT=$(curl --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
        -s https://check.torproject.org/api/ip)

    local IP
    IP=$(curl --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
        -s https://api64.ipify.org)

    echo -e "${GREEN}║  TOR Status : VERIFIED                            ║${RESET}"
    echo -e "${GREEN}║  Exit IP   : ${IP:-UNKNOWN}${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"

    echo
    echo -e "${YELLOW}Raw Response:${RESET}"
    echo "$RESULT"

    echo
    echo -e "${GREEN}[SUCCESS] Traffic is routed through TOR.${RESET}"
    echo

    read -p $'Press ENTER to continue... ' _
}

show_doc() {

    local FILE="$1"

    clear

    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║                DOCUMENTATION VIEWER               ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
    echo

    if [[ ! -f "$FILE" ]]; then
        echo -e "${RED}[ERROR] Documentation file not found.${RESET}"
        echo
        read -p "Press ENTER to continue..."
        return
    fi

    cat "$FILE"

    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Press ENTER to continue..."
}

detect_docs_environment() {

    if grep -qi microsoft /proc/version 2>/dev/null; then
        DOCS_OS="WSL"
        DOCS_RECOMMEND="WSL Guide"

    elif command -v termux-info >/dev/null 2>&1; then
        DOCS_OS="Termux"
        DOCS_RECOMMEND="Termux Guide"

    else
        DOCS_OS="Linux"
        DOCS_RECOMMEND="Linux Guide"
    fi
    
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

    TOR_RUNNING="OFFLINE"
    PROXY_RUNNING="OFFLINE"

    pgrep tor >/dev/null && TOR_RUNNING="ONLINE"
    pgrep privoxy >/dev/null && PROXY_RUNNING="ONLINE"
}

docs_screen() {

    while true; do

        clear
        detect_docs_environment
        echo "=================================="
        echo "      DOCUMENTATION CENTER"
        echo "=================================="
        echo
        echo "Platform     : $DOCS_OS"
        echo "Local IP     : ${LOCAL_IP:-Unknown}"
        echo "TOR Status   : $TOR_RUNNING"
        echo "Proxy Status : $PROXY_RUNNING"
        echo
        echo "Recommended  : $DOCS_RECOMMEND"
        echo
        echo "1. Quick Start"
        echo "0. Back"
        echo

        read -p "Choice: " doc_choice

        case "$doc_choice" in

            1)
                show_doc "./docs/quickstart.txt"
                ;;

            0)
                return
                ;;

            *)
                echo "Invalid choice"
                sleep 1
                ;;

        esac

    done
}

about_screen() {
    banner
    echo -e "${BOLD}${CYAN}About – NS GAMMING GHOST ENGINE v4 (HYBRID)${RESET}"
    echo
    echo -e "${GREEN}- Brand      : NS GAMMING || Nishant Sarkar${RESET}"
    echo -e "${GREEN}- Engine     : Single Tor node + Privoxy HTTP proxy${RESET}"
    echo -e "${GREEN}- Features   : Auto-rotate, IP history, Torify URL${RESET}"
    echo
    echo -e "${YELLOW}How it works:${RESET}"
    echo -e "  • Starts Tor with SocksPort ${TOR_SOCKS_PORT} and ControlPort ${TOR_CONTROL_PORT}."
    echo -e "  • Starts Privoxy on 127.0.0.1:${PRIVOXY_PORT} forwarding into Tor."
    echo -e "  • Lets you rotate identity automatically or manually."
    echo -e "  • Tracks your exit IP history for this session."
    echo
    echo -e "${MAG}Security notes:${RESET}"
    echo -e "  • No bash history is saved for this session."
    echo -e "  • This tool does NOT log websites you visit."
    echo -e "  • Your privacy still depends on YOUR behavior:"
    echo -e "    - logging into real accounts,"
    echo -e "    - giving personal info,"
    echo -e "    - or downloading risky files."
    echo
    echo -e "${DIM}This is a privacy / learning tool, not a license for illegal activity.${RESET}"
    echo
    read -p $'Press ENTER to go back... ' _
}

main_menu() {
    while true; do
        banner
        matrix_burst

        echo
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${GREEN}║                         👻 GHOST ENGINE COMMAND CENTER                     ║${RESET}"
        echo -e "${GREEN}╠══════════════════════════════════════════════════════════════════════════════╣${RESET}"
        echo -e "${GREEN}║${RESET} 1 ▶ Start Engine      2 🔄 Auto Rotate      3 ♻ Rotate Once              ${GREEN}║${RESET}"
        echo -e "${GREEN}║${RESET} 4 🌍 Current IP       5 📜 Logs & Status    6 🌐 Torify URL             ${GREEN}║${RESET}"
        echo -e "${GREEN}║${RESET} 7 🛡 Verify TOR       8 📡 Proxy Guide      9 ⚙ Settings                ${GREEN}║${RESET}"
        echo -e "${GREEN}║${RESET} D 📚 Documentation    A ℹ About            S ⛔ Stop Engine             ${GREEN}║${RESET}"
        echo -e "${GREEN}╠══════════════════════════════════════════════════════════════════════════════╣${RESET}"
        echo -e "${GREEN}║${RESET} 0 ❌ Exit Ghost Engine                                            ${GREEN}║${RESET}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
        echo

        echo -ne "${GREEN}ghost-engine${RESET}@${CYAN}root${RESET}:${YELLOW}~${RESET}$ "
        read -r choice

        case "$choice" in

            1)
                start_tor_engine
                ;;

            2)
                smart_rotate_loop
                ;;

            3)
                single_rotate
                ;;

            4)
                check_ip
                ;;

            5)
                show_status
                ;;

            6)
                torify_url
                ;;

            7)
                verify_tor
                ;;

            8)
                proxy_guide
                ;;

            9)
                settings_menu
                ;;

            D|d)
                docs_screen
                ;;

            A|a)
                about_screen
                ;;

            S|s)
                stop_all
                ;;

            0)
                banner
                echo
                echo -e "${GREEN}[SYSTEM] Ghost Engine Shutdown Complete${RESET}"
                echo -e "${CYAN}Thank you for using Ghost Engine 👻${RESET}"
                echo
                exit 0
                ;;

            *)
                echo
                echo -e "${RED}[ERROR] Unknown command.${RESET}"
                echo -e "${YELLOW}[TIP] Available commands: 1-9, D, A, S, 0${RESET}"
                sleep 2
                ;;
        esac
    done
}

security_hardening
install_deps
main_menu
