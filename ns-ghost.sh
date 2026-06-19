#!/data/data/com.termux/files/usr/bin/bash
# 💙 NS GAMMING – GHOST ENGINE v4 (HYBRID SINGLE NODE)
# Single Tor • ControlPort • Auto-Rotate • IP History • Hacker UI

PREFIX="/data/data/com.termux/files/usr"
BASE_DIR="$HOME/.ns_ghost"
TOR_DIR="$BASE_DIR/tor_single"
PRIVOXY_CONF="$BASE_DIR/privoxy.conf"

TOR_SOCKS_PORT=9050
TOR_CONTROL_PORT=9051
PRIVOXY_PORT=8118

LOG_FILE="$BASE_DIR/tor_debug.log"
IP_HISTORY=()

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
MAG="\e[35m"
RESET="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"

banner() {
    clear
    echo -e "${BLUE}${BOLD}┌────────────────────────────────────────────────┐${RESET}"
    echo -e "${BLUE}${BOLD}│ 💙 NS GAMMING – GHOST ENGINE v4 (HYBRID) 💙 │${RESET}"
    echo -e "${BLUE}${BOLD}│  Single Tor • Auto-Rotate • IP History • UI  │${RESET}"
    echo -e "${BLUE}${BOLD}└────────────────────────────────────────────────┘${RESET}"
    echo -e "${CYAN}${DIM}   Created for: NS GAMMING || Nishant Sarkar${RESET}"
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
listen-address 127.0.0.1:${PRIVOXY_PORT}
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
    IP=$(curl --proxy "http://127.0.0.1:${PRIVOXY_PORT}" -s https://api64.ipify.org 2>/dev/null)
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
    IP=$(curl --proxy "http://127.0.0.1:${PRIVOXY_PORT}" -s https://api64.ipify.org 2>/dev/null)
    remember_ip "$IP"
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
        IP=$(curl --proxy "http://127.0.0.1:${PRIVOXY_PORT}" -s https://api64.ipify.org 2>/dev/null)
        remember_ip "$IP"

        banner
        matrix_burst
        echo -e "${GREEN}🌐 Auto-Rotate Running${RESET}"
        echo -e "${GREEN}Current Tor Exit IP: ${BOLD}${IP:-UNKNOWN}${RESET}"
        echo -e "${BLUE}Proxy: 127.0.0.1:${PRIVOXY_PORT}${RESET}"
        echo -e "${CYAN}Requested interval: ${T}s (sleep is exact).${RESET}"
        echo
        show_ip_history
        echo
        echo -e "${MAG}CTRL + C to stop auto-rotation.${RESET}"
        sleep "$T"
    done
}

torify_url() {
    banner
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
        echo -e "${BOLD}${CYAN}Main Menu:${RESET}"
        echo -e "${BLUE} 1${RESET} - Start / Restart Ghost Engine"
        echo -e "${BLUE} 2${RESET} - Auto-Rotation Mode (Hybrid)"
        echo -e "${BLUE} 3${RESET} - Single Rotate + Show IPs"
        echo -e "${BLUE} 4${RESET} - Show Current IP + History"
        echo -e "${BLUE} 5${RESET} - Show Status & Last Logs"
        echo -e "${BLUE} 6${RESET} - Torify Single URL (curl via Tor)"
        echo -e "${BLUE} 7${RESET} - About / Credits"
        echo -e "${BLUE} 8${RESET} - Stop Tor + Proxy"
        echo -e "${RED} 0${RESET} - Exit"
        echo
        read -p "$(echo -e "${CYAN}Choice → ${RESET}")" choice
        case "$choice" in
            1) start_tor_engine ;;
            2) smart_rotate_loop ;;
            3) single_rotate ;;
            4) check_ip ;;
            5) show_status ;;
            6) torify_url ;;
            7) about_screen ;;
            8) stop_all ;;
            0) banner; echo -e "${GREEN}Exiting Ghost Engine v4. Stay invisible 👻💙${RESET}"; exit 0 ;;
            *) echo -e "${RED}[!] Invalid option.${RESET}"; sleep 1 ;;
        esac
    done
}

security_hardening
install_deps
main_menu
