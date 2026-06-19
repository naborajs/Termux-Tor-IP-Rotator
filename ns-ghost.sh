# ==========================================================
# 👻 GHOST ENGINE v5
# NS GAMING • Advanced TOR Identity Framework
# ==========================================================
PREFIX="${PREFIX:-/usr}"
BASE_DIR="$HOME/.ns_ghost"
TOR_DIR="$BASE_DIR/tor_single"
PRIVOXY_CONF="$BASE_DIR/privoxy.conf"
LOG_FILE="$BASE_DIR/tor_debug.log"
TOR_SOCKS_PORT=9050
TOR_CONTROL_PORT=9051
PRIVOXY_PORT=8118
SESSION_START=$(date +%s)
TOTAL_ROTATIONS=0
SUCCESS_COUNT=0
ERROR_COUNT=0
RESTART_COUNT=0
LAST_RESTART_TIME="Never"
IP_HISTORY=()
LAST_IP=""
CURRENT_IP="UNKNOWN"
DUPLICATE_COUNT=0
MAX_DUPLICATES=5
TOR_RUNNING="UNKNOWN"
PROXY_RUNNING="UNKNOWN"
PLATFORM_NAME="Unknown"
PROXY_HOST="127.0.0.1"
SHOW_MATRIX=true
SHOW_COLORS=true
ENGINE_NAME="Ghost Engine"
ENGINE_VERSION="v5"
ENGINE_AUTHOR="Naboraj Sarkar"
ENGINE_BRAND="NS CODEX"

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

    mkdir -p "$BASE_DIR"
    mkdir -p "$BASE_DIR/docs"
    mkdir -p "$TOR_DIR"

    touch "$LOG_FILE"

    export HISTFILE=/dev/null
    unset HISTFILE

    if command -v termux-wake-lock >/dev/null 2>&1; then
        termux-wake-lock >/dev/null 2>&1
    fi

    if grep -qi microsoft /proc/version 2>/dev/null; then
        PLATFORM_NAME="WSL"

    elif command -v termux-info >/dev/null 2>&1; then
        PLATFORM_NAME="Termux"

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM_NAME="macOS"

    else
        PLATFORM_NAME="Linux"
    fi

    echo "========================================" >> "$LOG_FILE"
    echo "Ghost Engine Startup" >> "$LOG_FILE"
    echo "Date: $(date)" >> "$LOG_FILE"
    echo "Platform: $PLATFORM_NAME" >> "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"

    : > "$BASE_DIR/runtime.lock"

}

install_deps() {

local DEPS_MARKER="$BASE_DIR/.deps_installed"
local SILENT="${1:-false}"

if [[ -f "$DEPS_MARKER" ]]; then
    return 0
fi

[[ "$SILENT" != "true" ]] && {
    clear
    echo -e "${CYAN}[SYSTEM] Checking Dependencies...${RESET}"
    echo
}

local REQUIRED=(
    tor
    curl
)

local MISSING=()

for cmd in "${REQUIRED[@]}"; do

    if ! command -v "$cmd" >/dev/null 2>&1; then
        MISSING+=("$cmd")
    fi

done

if command -v nc >/dev/null 2>&1; then
    :
else
    MISSING+=("netcat")
fi

if (( ${#MISSING[@]} == 0 )); then

    touch "$DEPS_MARKER"

    [[ "$SILENT" != "true" ]] && {
        echo -e "${GREEN}[OK] All dependencies already installed.${RESET}"
        sleep 1
    }

    return 0

fi

[[ "$SILENT" != "true" ]] && {
    echo -e "${YELLOW}[INFO] Missing:${RESET} ${MISSING[*]}"
    echo
}

if command -v pkg >/dev/null 2>&1; then

    [[ "$SILENT" != "true" ]] && \
    echo -e "${CYAN}[TERMUX] Installing packages...${RESET}"

    pkg update -y >/dev/null 2>&1

    pkg install -y \
        tor \
        privoxy \
        curl \
        netcat-openbsd >/dev/null 2>&1

elif command -v apt >/dev/null 2>&1; then

    [[ "$SILENT" != "true" ]] && \
    echo -e "${CYAN}[APT] Installing packages...${RESET}"

    sudo apt update -y >/dev/null 2>&1

    sudo apt install -y \
        tor \
        privoxy \
        curl \
        netcat-openbsd >/dev/null 2>&1

elif command -v pacman >/dev/null 2>&1; then

    [[ "$SILENT" != "true" ]] && \
    echo -e "${CYAN}[PACMAN] Installing packages...${RESET}"

    sudo pacman -Sy --noconfirm \
        tor \
        privoxy \
        curl \
        openbsd-netcat >/dev/null 2>&1

elif command -v dnf >/dev/null 2>&1; then

    [[ "$SILENT" != "true" ]] && \
    echo -e "${CYAN}[DNF] Installing packages...${RESET}"

    sudo dnf install -y \
        tor \
        privoxy \
        curl \
        nc >/dev/null 2>&1

elif command -v yum >/dev/null 2>&1; then

    [[ "$SILENT" != "true" ]] && \
    echo -e "${CYAN}[YUM] Installing packages...${RESET}"

    sudo yum install -y \
        tor \
        privoxy \
        curl \
        nc >/dev/null 2>&1

elif command -v brew >/dev/null 2>&1; then

    [[ "$SILENT" != "true" ]] && \
    echo -e "${CYAN}[HOMEBREW] Installing packages...${RESET}"

    brew install \
        tor \
        privoxy \
        curl \
        netcat >/dev/null 2>&1

else

    echo
    echo -e "${RED}[ERROR] Unsupported package manager.${RESET}"
    echo -e "${RED}[ERROR] Please install Tor, Privoxy, Curl and Netcat manually.${RESET}"
    return 1

fi

if command -v tor >/dev/null 2>&1 &&
   command -v curl >/dev/null 2>&1 &&
   command -v nc >/dev/null 2>&1; then

    touch "$DEPS_MARKER"

    [[ "$SILENT" != "true" ]] && {
        echo
        echo -e "${GREEN}[SUCCESS] Dependencies installed successfully.${RESET}"
        sleep 1
    }

    return 0

fi

echo
echo -e "${RED}[ERROR] Dependency verification failed.${RESET}"

return 1

}


check_tor() {

if ! nc -z 127.0.0.1 "$TOR_SOCKS_PORT" >/dev/null 2>&1; then
    return 1
fi

local TEST_IP

TEST_IP=$(curl \
    --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
    --max-time 10 \
    -s \
    https://api64.ipify.org)

[[ -n "$TEST_IP" ]]

}


check_privoxy_port() {
    nc -z 127.0.0.1 "$PRIVOXY_PORT" >/dev/null 2>&1
}

check_privoxy() {

    check_privoxy_port || return 1

    curl \
        --proxy "http://127.0.0.1:${PRIVOXY_PORT}" \
        --max-time 10 \
        -s \
        https://api64.ipify.org \
        >/dev/null 2>&1
}

remember_ip() {

    local ip="$1"

    [[ -z "$ip" ]] && return

    CURRENT_IP="$ip"

    if [[ "$ip" == "$LAST_RECORDED_IP" ]]; then
        return
    fi

    LAST_RECORDED_IP="$ip"

    IP_HISTORY+=("$ip")

    ((UNIQUE_IP_COUNT++))

    echo "$(date '+%Y-%m-%d %H:%M:%S') | New Exit IP: $ip" >> "$LOG_FILE"

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

    if (( DUPLICATE_COUNT < MAX_DUPLICATES )); then
        return
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') | Duplicate IP threshold reached (${current_ip})" >> "$LOG_FILE"

    ((RESTART_COUNT++))
    LAST_RESTART_TIME=$(date '+%H:%M:%S')

    pkill tor 2>/dev/null
    pkill privoxy 2>/dev/null

    sleep 3

    start_tor_engine true >/dev/null 2>&1

    local tries=0

    while (( tries < 30 )); do

        if check_tor && check_privoxy; then
            break
        fi

        sleep 2
        ((tries++))

    done

    if ! check_tor || ! check_privoxy; then

        ((ERROR_COUNT++))

        echo "$(date '+%Y-%m-%d %H:%M:%S') | Engine restart failed" >> "$LOG_FILE"

        DUPLICATE_COUNT=0
        return

    fi

    local new_ip=""
    local attempt=0

    while (( attempt < 10 )); do

        sleep 5

        new_ip=$(curl \
            --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
            -s \
            --max-time 15 \
            https://api64.ipify.org)

        [[ -z "$new_ip" ]] && {
            ((attempt++))
            continue
        }

        if [[ "$new_ip" != "$current_ip" ]]; then

            remember_ip "$new_ip"

            ((SUCCESS_COUNT++))

            echo "$(date '+%Y-%m-%d %H:%M:%S') | New IP acquired: $new_ip" >> "$LOG_FILE"

            DUPLICATE_COUNT=0
            LAST_IP="$new_ip"

            return

        fi

        echo -e "AUTHENTICATE \"\"\r\nSIGNAL NEWNYM\r\nQUIT" \
            | nc 127.0.0.1 "$TOR_CONTROL_PORT" >/dev/null 2>&1

        ((attempt++))

    done

    ((ERROR_COUNT++))

    echo "$(date '+%Y-%m-%d %H:%M:%S') | Failed to obtain a new IP after restart" >> "$LOG_FILE"

    DUPLICATE_COUNT=0
}

show_ip_history() {

    echo -e "${CYAN}📜 IP History (${#IP_HISTORY[@]} Recorded)${RESET}"

    if (( ${#IP_HISTORY[@]} == 0 )); then
        echo -e "  ${DIM}(No IPs recorded yet)${RESET}"
        return
    fi

    local idx=1

    for ip in "${IP_HISTORY[@]}"; do

        if [[ "$ip" == "$LAST_IP" ]]; then
            echo -e "  ${MAG}#${idx}${RESET} ${GREEN}${ip}${RESET} ${YELLOW}(CURRENT)${RESET}"
        else
            echo -e "  ${MAG}#${idx}${RESET} ${GREEN}${ip}${RESET}"
        fi

        ((idx++))
    done

    echo
    echo -e "${CYAN}Unique IPs:${RESET} $(printf "%s\n" "${IP_HISTORY[@]}" | sort -u | wc -l)"
}

start_tor_engine() {

    local SILENT="${1:-false}"

    detect_platform

    if [[ "$SILENT" != "true" ]]; then

        clear

        echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║                GHOST ENGINE STARTUP               ║${RESET}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
        echo

        printf "%-18s %s\n" "Platform:" "$PLATFORM_NAME"
        printf "%-18s %s\n" "SOCKS5 Port:" "$TOR_SOCKS_PORT"
        printf "%-18s %s\n" "Control Port:" "$TOR_CONTROL_PORT"
        printf "%-18s %s\n" "HTTP Proxy Port:" "$PRIVOXY_PORT"

        echo
        echo -e "${YELLOW}[1/5] Cleaning Previous Session...${RESET}"
    fi

    pkill tor 2>/dev/null
    pkill privoxy 2>/dev/null

    sleep 2

    mkdir -p "$TOR_DIR"
    mkdir -p "$TOR_DIR/data"

    touch "$LOG_FILE"

    local TORRC="$TOR_DIR/torrc"

    cat > "$TORRC" <<EOF
SocksPort 127.0.0.1:${TOR_SOCKS_PORT}
ControlPort 127.0.0.1:${TOR_CONTROL_PORT}
CookieAuthentication 0
AvoidDiskWrites 1
DataDirectory ${TOR_DIR}/data
EOF

    [[ "$SILENT" != "true" ]] && \
    echo -e "${YELLOW}[2/5] Starting TOR Service...${RESET}"

    echo "$(date '+%Y-%m-%d %H:%M:%S') | Starting TOR" >> "$LOG_FILE"

    tor -f "$TORRC" >> "$LOG_FILE" 2>&1 &

    local TOR_READY=false

    for ((i=1;i<=60;i++)); do

        if nc -z 127.0.0.1 "$TOR_SOCKS_PORT" >/dev/null 2>&1; then
            TOR_READY=true
            break
        fi

        sleep 1

    done

    if [[ "$TOR_READY" != "true" ]]; then

        ((ERROR_COUNT++))

        echo "$(date '+%Y-%m-%d %H:%M:%S') | TOR startup failed" >> "$LOG_FILE"

        [[ "$SILENT" != "true" ]] && {
            echo
            echo -e "${RED}[ERROR] TOR failed to start.${RESET}"
            echo -e "${YELLOW}Check logs from Status Menu.${RESET}"
            sleep 3
        }

        return 1

    fi

    [[ "$SILENT" != "true" ]] && \
    echo -e "${GREEN}[OK] TOR Online${RESET}"

    cat > "$PRIVOXY_CONF" <<EOF
listen-address 0.0.0.0:${PRIVOXY_PORT}
toggle 1
enable-remote-toggle 0
enable-remote-http-toggle 0
accept-intercepted-requests 0
allow-cgi-request-crunching 0
forwarded-connect-retries 1
forward-socks5 / 127.0.0.1:${TOR_SOCKS_PORT} .
EOF

    [[ "$SILENT" != "true" ]] && \
    echo -e "${YELLOW}[3/5] Starting HTTP Proxy...${RESET}"

    echo "$(date '+%Y-%m-%d %H:%M:%S') | Starting Privoxy" >> "$LOG_FILE"

    privoxy "$PRIVOXY_CONF" >> "$LOG_FILE" 2>&1 &

    local PROXY_READY=false

    for ((i=1;i<=30;i++)); do

        if nc -z 127.0.0.1 "$PRIVOXY_PORT" >/dev/null 2>&1; then
            PROXY_READY=true
            break
        fi

        sleep 1

    done

    if [[ "$PROXY_READY" != "true" ]]; then

        ((ERROR_COUNT++))

        echo "$(date '+%Y-%m-%d %H:%M:%S') | Privoxy startup failed" >> "$LOG_FILE"

        [[ "$SILENT" != "true" ]] && {
            echo
            echo -e "${RED}[ERROR] Privoxy failed to start.${RESET}"
            sleep 3
        }

        return 1

    fi

    [[ "$SILENT" != "true" ]] && \
    echo -e "${GREEN}[OK] Proxy Online${RESET}"

    [[ "$SILENT" != "true" ]] && \
    echo -e "${YELLOW}[4/5] Verifying Exit Node...${RESET}"

    CURRENT_IP=$(curl \
        --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
        --max-time 15 \
        -s \
        https://api64.ipify.org)

    [[ -n "$CURRENT_IP" ]] && remember_ip "$CURRENT_IP"

    LAST_START_TIME=$(date '+%H:%M:%S')

    if grep -qi microsoft /proc/version 2>/dev/null; then

        PROXY_HOST=$(hostname -I 2>/dev/null | awk '{print $1}')

        [[ -z "$PROXY_HOST" ]] && \
        PROXY_HOST=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')

        [[ -z "$PROXY_HOST" ]] && \
        PROXY_HOST="127.0.0.1"

    else

        PROXY_HOST="127.0.0.1"

    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') | Engine Started Successfully" >> "$LOG_FILE"

    [[ "$SILENT" == "true" ]] && return 0

    echo
    echo -e "${GREEN}[5/5] Startup Complete${RESET}"
    echo

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}        GHOST ENGINE ONLINE${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    printf "%-18s %s\n" "Platform:" "$PLATFORM_NAME"
    printf "%-18s %s\n" "Current IP:" "${CURRENT_IP:-UNKNOWN}"
    printf "%-18s %s\n" "SOCKS5 Proxy:" "127.0.0.1:${TOR_SOCKS_PORT}"
    printf "%-18s %s\n" "HTTP Proxy:" "${PROXY_HOST}:${PRIVOXY_PORT}"
    printf "%-18s %s\n" "Started:" "$LAST_START_TIME"

    echo

    case "$PLATFORM_NAME" in

        WSL)
            echo -e "${YELLOW}Windows Setup:${RESET}"
            echo -e "Use ${PROXY_HOST}:${PRIVOXY_PORT}"
            echo
            ;;

        Termux)
            echo -e "${YELLOW}Android Setup:${RESET}"
            echo -e "Wi-Fi → Modify Network → Proxy → Manual"
            echo -e "Host: 127.0.0.1"
            echo -e "Port: ${PRIVOXY_PORT}"
            echo
            ;;

        Linux)
            echo -e "${YELLOW}Linux Setup:${RESET}"
            echo -e "Configure your browser/app proxy settings."
            echo
            ;;

        macOS)
            echo -e "${YELLOW}macOS Setup:${RESET}"
            echo -e "System Settings → Network → Proxies"
            echo
            ;;

    esac

    read -p $'Press ENTER to continue... ' _
}

stop_all() {

clear
detect_platform

echo -e "${RED}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${RED}║                ENGINE SHUTDOWN                    ║${RESET}"
echo -e "${RED}╚════════════════════════════════════════════════════╝${RESET}"
echo

echo -e "${YELLOW}[1/4] Stopping TOR Service...${RESET}"

if pgrep tor >/dev/null; then
    pkill tor 2>/dev/null
    sleep 1

    if pgrep tor >/dev/null; then
        echo -e "${RED}[FAILED] TOR still running.${RESET}"
    else
        echo -e "${GREEN}[OK] TOR stopped successfully.${RESET}"
    fi
else
    echo -e "${YELLOW}[INFO] TOR already stopped.${RESET}"
fi

echo
echo -e "${YELLOW}[2/4] Stopping Proxy Service...${RESET}"

if pgrep privoxy >/dev/null; then
    pkill privoxy 2>/dev/null
    sleep 1

    if pgrep privoxy >/dev/null; then
        echo -e "${RED}[FAILED] Proxy still running.${RESET}"
    else
        echo -e "${GREEN}[OK] Proxy stopped successfully.${RESET}"
    fi
else
    echo -e "${YELLOW}[INFO] Proxy already stopped.${RESET}"
fi

echo
echo -e "${YELLOW}[3/4] Cleaning Session...${RESET}"

echo -e "${GREEN}[OK] Rotation Count : $TOTAL_ROTATIONS${RESET}"
echo -e "${GREEN}[OK] Saved IPs      : ${#IP_HISTORY[@]}${RESET}"

echo
echo -e "${YELLOW}[4/4] Final Checks...${RESET}"

if ! pgrep tor >/dev/null && ! pgrep privoxy >/dev/null; then
    echo -e "${GREEN}[SUCCESS] Ghost Engine Shutdown Complete${RESET}"
else
    echo -e "${RED}[WARNING] Some processes may still be running.${RESET}"
fi

echo
echo -e "${CYAN}Platform:${RESET} $PLATFORM_NAME"

if grep -qi microsoft /proc/version 2>/dev/null; then

    echo
    echo -e "${YELLOW}WSL NOTICE${RESET}"
    echo -e "If Windows Proxy is enabled,"
    echo -e "disable it now to restore direct connectivity."

fi

echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

echo -e "${GREEN}Thank you for using Ghost Engine 👻${RESET}"
echo -e "${DIM}Session Duration: $(printf '%02dh %02dm %02ds' \
$(( ( $(date +%s ) - SESSION_START ) / 3600 )) \
$(( (( $(date +%s ) - SESSION_START ) % 3600 ) / 60 )) \
$(( ( $(date +%s ) - SESSION_START ) % 60 )))${RESET}"

echo
read -p $'Press ENTER to continue... ' _

}


show_status() {

clear
detect_platform
detect_status

NOW=$(date +%s)
UPTIME=$((NOW - SESSION_START))

echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║                 SYSTEM STATUS                     ║${RESET}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
echo

echo -e "${GREEN}ENGINE INFORMATION${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

printf "%-20s %s\n" "Platform:" "$PLATFORM_NAME"
printf "%-20s %s\n" "Current IP:" "${CURRENT_IP:-UNKNOWN}"
printf "%-20s %s\n" "Proxy:" "${PROXY_HOST}:${PRIVOXY_PORT}"

echo

echo -e "${GREEN}SERVICE STATUS${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if check_tor; then
    echo -e "TOR Service      : ${GREEN}ONLINE${RESET}"
else
    echo -e "TOR Service      : ${RED}OFFLINE${RESET}"
fi

if check_privoxy; then
    echo -e "Proxy Service    : ${GREEN}ONLINE${RESET}"
else
    echo -e "Proxy Service    : ${RED}OFFLINE${RESET}"
fi

echo
echo -e "${GREEN}SESSION STATISTICS${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

printf "%-20s %s\n" "Rotations:" "$TOTAL_ROTATIONS"
printf "%-20s %s\n" "Saved IPs:" "${#IP_HISTORY[@]}"
printf "%-20s %s\n" "Duplicates:" "$DUPLICATE_COUNT/$MAX_DUPLICATES"

printf "%-20s %s\n" "Uptime:" \
"$(printf '%02dh %02dm %02ds' \
$((UPTIME/3600)) \
$(((UPTIME%3600)/60)) \
$((UPTIME%60)))"

echo

echo -e "${GREEN}NETWORK PORTS${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "SOCKS5 Port      : 127.0.0.1:${TOR_SOCKS_PORT}"
echo -e "Control Port     : 127.0.0.1:${TOR_CONTROL_PORT}"
echo -e "HTTP Proxy       : ${PROXY_HOST}:${PRIVOXY_PORT}"

echo

echo -e "${GREEN}RECENT LOGS${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

tail -n 8 "$LOG_FILE" 2>/dev/null || echo "No logs available."

echo

echo -e "${GREEN}IP HISTORY${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ ${#IP_HISTORY[@]} -eq 0 ]]; then

    echo "No IP history available."

else

    for ip in "${IP_HISTORY[@]}"; do
        echo "• $ip"
    done

fi

echo

if grep -qi microsoft /proc/version 2>/dev/null; then

    echo -e "${YELLOW}WSL INFORMATION${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo -e "WSL IP : ${PROXY_HOST}"
    echo -e "Windows users should use:"
    echo -e "${PROXY_HOST}:${PRIVOXY_PORT}"

    echo

fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${CYAN}Tip:${RESET} Run Verify TOR regularly to confirm routing."
echo

read -p $'Press ENTER to continue... ' _

}


check_ip() {

clear

if ! check_privoxy || ! check_tor; then

    echo -e "${YELLOW}[SYSTEM] Engine offline. Starting...${RESET}"

    start_tor_engine || return

fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${CYAN}               IP INFORMATION                ${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo

REAL_IP=$(curl -s --max-time 10 https://api64.ipify.org)

TOR_IP=$(curl \
    --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
    -s \
    --max-time 15 \
    https://api64.ipify.org)

remember_ip "$TOR_IP"

echo -e "🌍 TOR IP   : ${GREEN}${BOLD}${TOR_IP:-UNKNOWN}${RESET}"
echo -e "💻 REAL IP  : ${YELLOW}${REAL_IP:-UNKNOWN}${RESET}"

echo

if [[ "$REAL_IP" != "$TOR_IP" && -n "$TOR_IP" ]]; then

    echo -e "🛡 Status   : ${GREEN}TOR ACTIVE${RESET}"

else

    echo -e "⚠ Status   : ${RED}TOR NOT VERIFIED${RESET}"

fi

echo -e "🔒 SOCKS5   : 127.0.0.1:${TOR_SOCKS_PORT}"
echo -e "🌐 PROXY    : ${PROXY_HOST}:${PRIVOXY_PORT}"

echo

if [[ ${#IP_HISTORY[@]} -gt 0 ]]; then

    echo -e "${CYAN}Recent TOR IPs:${RESET}"

    for ip in "${IP_HISTORY[@]: -5}"; do
        echo " • $ip"
    done

fi

echo
read -p $'Press ENTER to continue... ' _

}


single_rotate() {

clear

if ! check_privoxy || ! check_tor; then

    echo -e "${YELLOW}[SYSTEM] Engine offline. Starting...${RESET}"

    start_tor_engine || return

fi

OLD_IP=$(curl \
    --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
    -s \
    --max-time 10 \
    https://api64.ipify.org)

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${CYAN}              TOR IDENTITY ROTATION           ${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo

echo -e "${YELLOW}[ROTATING] Requesting new TOR identity...${RESET}"

echo -e "AUTHENTICATE \"\"\r\nSIGNAL NEWNYM\r\nQUIT" \
    | nc 127.0.0.1 "$TOR_CONTROL_PORT" >/dev/null 2>&1

sleep 4

NEW_IP=$(curl \
    --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
    -s \
    --max-time 10 \
    https://api64.ipify.org)

remember_ip "$NEW_IP"

((TOTAL_ROTATIONS++))

echo

echo -e "📍 Previous IP : ${YELLOW}${OLD_IP:-UNKNOWN}${RESET}"
echo -e "🌍 Current IP  : ${GREEN}${NEW_IP:-UNKNOWN}${RESET}"

echo

if [[ "$OLD_IP" != "$NEW_IP" ]]; then

    echo -e "✅ Status      : ${GREEN}IP CHANGED${RESET}"

else

    echo -e "⚠ Status      : ${YELLOW}SAME EXIT NODE${RESET}"

fi

echo -e "🔄 Rotations   : $TOTAL_ROTATIONS"
echo -e "📚 IP History  : ${#IP_HISTORY[@]}"

echo

if [[ ${#IP_HISTORY[@]} -gt 1 ]]; then

    echo -e "${CYAN}Recent IPs:${RESET}"

    for ip in "${IP_HISTORY[@]: -5}"; do
        echo " • $ip"
    done

fi

echo
read -p $'Press ENTER to continue... ' _

}


smart_rotate_loop() {

clear

detect_platform

echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║             AUTO ROTATION DASHBOARD              ║${RESET}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
echo

read -p "Rotation Interval (seconds, min 3): " T

[[ ! "$T" =~ ^[0-9]+$ ]] && T=10
(( T < 3 )) && T=3

while true; do

    if ! check_tor || ! check_privoxy; then

        ((ERROR_COUNT++))

        echo
        echo -e "${YELLOW}[RECOVERY] Engine offline. Restarting...${RESET}"

        start_tor_engine true >/dev/null 2>&1

        local WAIT_COUNT=0

        while (( WAIT_COUNT < 30 )); do

            if check_tor && check_privoxy; then
                break
            fi

            sleep 2
            ((WAIT_COUNT++))

        done

        if ! check_tor || ! check_privoxy; then

            ((ERROR_COUNT++))

            echo -e "${RED}[ERROR] Recovery failed.${RESET}"

            sleep 5
            continue

        fi

        ((RESTART_COUNT++))

    fi

    PREVIOUS_IP="$CURRENT_IP"

    echo -e "AUTHENTICATE \"\"\r\nSIGNAL NEWNYM\r\nQUIT" \
        | nc 127.0.0.1 "$TOR_CONTROL_PORT" >/dev/null 2>&1

    sleep 5

    IP=$(curl \
        --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
        -s \
        --max-time 15 \
        https://api64.ipify.org)

    if [[ -z "$IP" ]]; then

        ((ERROR_COUNT++))

        sleep "$T"
        continue

    fi

    CURRENT_IP="$IP"

    remember_ip "$IP"

    ((TOTAL_ROTATIONS++))

    if [[ "$CURRENT_IP" != "$PREVIOUS_IP" ]]; then
        ((SUCCESS_COUNT++))
    fi

    check_duplicate_ip "$IP"

    NOW=$(date +%s)
    UPTIME=$((NOW - SESSION_START))

    clear

    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║             AUTO ROTATION DASHBOARD              ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
    echo

    printf "%-18s %s\n" "Platform:" "$PLATFORM_NAME"
    printf "%-18s %s\n" "Current IP:" "$CURRENT_IP"
    printf "%-18s %s\n" "Previous IP:" "${PREVIOUS_IP:-N/A}"

    echo

    printf "%-18s %s\n" "Rotations:" "$TOTAL_ROTATIONS"
    printf "%-18s %s\n" "Successes:" "$SUCCESS_COUNT"
    printf "%-18s %s\n" "Errors:" "$ERROR_COUNT"
    printf "%-18s %s\n" "Restarts:" "$RESTART_COUNT"

    echo

    printf "%-18s %s\n" "Duplicates:" "$DUPLICATE_COUNT/$MAX_DUPLICATES"
    printf "%-18s %s\n" "Stored IPs:" "${#IP_HISTORY[@]}"

    echo

    printf "%-18s %s\n" "SOCKS5:" "127.0.0.1:${TOR_SOCKS_PORT}"
    printf "%-18s %s\n" "Proxy:" "${PROXY_HOST}:${PRIVOXY_PORT}"

    echo

    printf "%-18s %s\n" \
    "Uptime:" \
    "$(printf '%02dh %02dm %02ds' \
    $((UPTIME/3600)) \
    $(((UPTIME%3600)/60)) \
    $((UPTIME%60)))"

    echo
    echo -e "${CYAN}Recent IP History${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if (( ${#IP_HISTORY[@]} == 0 )); then

        echo "No IPs recorded."

    else

        for ip in "${IP_HISTORY[@]: -10}"; do
            echo " • $ip"
        done

    fi

    echo
    echo -e "${GREEN}Status: Monitoring & Rotating Automatically${RESET}"
    echo -e "${DIM}Press CTRL+C to stop.${RESET}"

    sleep "$T"

done

}


torify_url() {

detect_platform

if ! check_privoxy || ! check_tor; then

    echo -e "${RED}[!] Engine is not running.${RESET}"
    echo -e "${YELLOW}[+] Starting Ghost Engine...${RESET}"

    start_tor_engine || return

fi

clear

echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║                  TORIFY URL TOOL                  ║${RESET}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
echo

echo -e "${GREEN}Platform:${RESET} $PLATFORM_NAME"
echo -e "${GREEN}Proxy:${RESET} ${PROXY_HOST}:${PRIVOXY_PORT}"
echo

read -p "Enter URL: " URL

if [[ -z "$URL" ]]; then

    echo
    echo -e "${RED}[ERROR] No URL entered.${RESET}"
    sleep 2
    return

fi

if [[ ! "$URL" =~ ^https?:// ]]; then

    echo
    echo -e "${YELLOW}[INFO] Adding https:// automatically...${RESET}"
    URL="https://$URL"

fi

echo
echo -e "${YELLOW}[+] Verifying TOR route...${RESET}"

TOR_IP=$(curl \
    --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
    -s \
    https://api64.ipify.org)

echo -e "${GREEN}[TOR EXIT]${RESET} ${TOR_IP:-UNKNOWN}"
echo

echo -e "${YELLOW}[+] Fetching URL through TOR...${RESET}"
echo

HTTP_CODE=$(curl \
    --proxy "http://127.0.0.1:${PRIVOXY_PORT}" \
    --max-time 20 \
    -s \
    -o /tmp/ghost_response.txt \
    -w "%{http_code}" \
    "$URL")

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}Request Summary${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

echo -e "URL         : $URL"
echo -e "Status Code : $HTTP_CODE"
echo -e "TOR Exit IP : ${TOR_IP:-UNKNOWN}"

echo

if [[ "$HTTP_CODE" == "200" ]]; then

    echo -e "${GREEN}[SUCCESS] Request completed.${RESET}"

else

    echo -e "${YELLOW}[WARNING] Server returned HTTP ${HTTP_CODE}.${RESET}"

fi

echo
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}Response Preview${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo

head -n 30 /tmp/ghost_response.txt

echo
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

rm -f /tmp/ghost_response.txt

echo
read -p $'Press ENTER to continue... ' _

}


project_info() {


clear

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║                 PROJECT & COMMUNITY HUB                  ║${RESET}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
echo

echo -e "${GREEN}ABOUT GHOST ENGINE${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Ghost Engine is an open-source TOR privacy toolkit"
echo -e "built to help users learn networking, anonymity,"
echo -e "proxy configuration and TOR routing."
echo
echo -e "Features:"
echo -e " • TOR Integration"
echo -e " • HTTP & SOCKS5 Proxy"
echo -e " • Auto Identity Rotation"
echo -e " • IP History Tracking"
echo -e " • Multi-Platform Support"
echo -e " • Documentation Center"
echo

echo -e "${GREEN}CONTRIBUTING${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Want to contribute?"
echo
echo -e "1. Fork the repository"
echo -e "2. Create a feature branch"
echo -e "3. Make improvements"
echo -e "4. Submit a Pull Request"
echo
echo -e "All contributions are welcome."
echo

echo -e "${GREEN}PROJECT LINKS${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "⭐GitHub Repository:"
echo -e "https://github.com/naborajs/Termux-Tor-IP-Rotator"
echo

echo -e "${GREEN}CONNECT WITH THE CREATOR${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "🌐 GitHub     : github.com/naborajs"
echo -e "▶ YouTube    : @Nishant_sarkar"
echo -e "📸 Instagram : @naborajs"
echo -e "💬 Telegram  : @Nishantsarkar10k"
echo -e "🐦 X/Twitter : @NSGAMMING699"
echo -e "💼 LinkedIn  : naboraj-sarkar"
echo

echo -e "${GREEN}SPECIAL MESSAGE${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "\"Thank you for checking out Ghost Engine."
echo -e "Whether you're here to learn, contribute,"
echo -e "or just explore, you're part of the journey.\""
echo

echo -e "${YELLOW}👻 Keep Learning. Keep Building. Keep Exploring.${RESET}"
echo
read -p $'Press ENTER to return... ' _

}


verify_tor() {

banner
detect_platform

echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║                TOR VERIFICATION                   ║${RESET}"
echo -e "${CYAN}╠════════════════════════════════════════════════════╣${RESET}"

echo -e "${YELLOW}[1/5] Detecting Platform...${RESET}"
echo -e "Platform: ${GREEN}$PLATFORM_NAME${RESET}"
echo

echo -e "${YELLOW}[2/5] Checking Internet...${RESET}"

if ! curl -s --max-time 10 https://api64.ipify.org >/dev/null; then

    echo -e "${RED}[FAILED] No Internet Connection.${RESET}"
    echo
    read -p $'Press ENTER to continue... ' _
    return

fi

echo -e "${GREEN}[OK] Internet Reachable${RESET}"
echo

echo -e "${YELLOW}[3/5] Checking TOR Service...${RESET}"

if ! check_tor; then

    echo -e "${RED}[FAILED] TOR Service Offline${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${YELLOW}Try:${RESET}"
    echo -e "  1 ▶ Start Engine"
    echo
    read -p $'Press ENTER to continue... ' _
    return

fi

echo -e "${GREEN}[OK] TOR Service Running${RESET}"
echo

echo -e "${YELLOW}[4/5] Checking Proxy Service...${RESET}"

if check_privoxy; then
    echo -e "${GREEN}[OK] Proxy Running${RESET}"
else
    echo -e "${RED}[WARNING] Proxy Offline${RESET}"
fi

echo

echo -e "${YELLOW}[5/5] Verifying TOR Routing...${RESET}"

REAL_IP=$(curl -s https://api64.ipify.org)

TOR_IP=$(curl \
    --socks5 127.0.0.1:${TOR_SOCKS_PORT} \
    -s \
    https://api64.ipify.org)

if [[ -z "$TOR_IP" ]]; then

    echo -e "${RED}[FAILED] Unable to obtain TOR Exit IP${RESET}"
    echo
    read -p $'Press ENTER to continue... ' _
    return

fi

echo
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║                 VERIFICATION PASSED               ║${RESET}"
echo -e "${GREEN}╠════════════════════════════════════════════════════╣${RESET}"

printf " %-18s %s\n" "Platform:" "$PLATFORM_NAME"
printf " %-18s %s\n" "Real IP:" "${REAL_IP:-UNKNOWN}"
printf " %-18s %s\n" "TOR Exit IP:" "${TOR_IP:-UNKNOWN}"
printf " %-18s %s\n" "SOCKS5:" "127.0.0.1:${TOR_SOCKS_PORT}"
printf " %-18s %s\n" "HTTP Proxy:" "${PROXY_HOST}:${PRIVOXY_PORT}"

echo
echo -e "${GREEN}[SUCCESS] Traffic is successfully routed through TOR.${RESET}"

if [[ "$REAL_IP" == "$TOR_IP" ]]; then

    echo
    echo -e "${RED}[WARNING] Real IP and TOR IP are identical.${RESET}"
    echo -e "${YELLOW}TOR routing may not be active.${RESET}"

else

    echo
    echo -e "${GREEN}[OK] TOR Exit IP differs from your real IP.${RESET}"

fi

echo
echo -e "${CYAN}Quick Test:${RESET}"
echo -e "curl --socks5 127.0.0.1:${TOR_SOCKS_PORT} https://api64.ipify.org"

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

    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║                DOCUMENTATION CENTER               ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
    echo

    echo -e "${GREEN}SYSTEM INFORMATION${RESET}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    printf "%-18s %s\n" "Platform:" "$DOCS_OS"
    printf "%-18s %s\n" "Local IP:" "${LOCAL_IP:-Unknown}"
    printf "%-18s %s\n" "TOR Status:" "$TOR_RUNNING"
    printf "%-18s %s\n" "Proxy Status:" "$PROXY_RUNNING"

    echo
    echo -e "${YELLOW}RECOMMENDED GUIDE${RESET}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⭐ $DOCS_RECOMMEND"
    echo

    echo -e "${BLUE}AVAILABLE DOCUMENTATION${RESET}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "1) 📖 Quick Start Guide"
    echo "2) 🐧 Linux Guide"
    echo "3) 🖥 WSL Guide"
    echo "4) 🧠 WSL Deep Dive"
    echo "5) 📱 Termux Guide"
    echo "6) 🛠 Troubleshooting Guide"     

    echo
    echo "R) Open Recommended Guide"
    echo "B) Back"

    echo
    read -p "Choice: " doc_choice

    case "$doc_choice" in

        1)
            show_doc "./docs/quickstart.txt"
            ;;

        2)
            show_doc "./docs/linux.txt"
            ;;

        3)
            show_doc "./docs/wsl.txt"
            ;;

        4)
            show_doc "./docs/wsl-explained.txt"
            ;;

        5)
            show_doc "./docs/termux.txt"
            ;;

        6)
            show_doc "./docs/troubleshooting.txt"
            ;;

        R|r)

            case "$DOCS_OS" in

                WSL)
                    show_doc "./docs/wsl.txt"
                    ;;

                Termux)
                    show_doc "./docs/termux.txt"
                    ;;

                Linux)
                    show_doc "./docs/linux.txt"
                    ;;

            esac
            ;;

        B|b|0)
            return
            ;;

        *)
            echo
            echo "Invalid choice."
            sleep 1
            ;;

    esac

done


}

settings_menu() {

    while true; do

        clear

        echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║                   SETTINGS MENU                   ║${RESET}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
        echo

        echo "1) Change Duplicate Threshold"
        echo "2) Reset Session Statistics"
        echo
        echo "Current Duplicate Limit : $MAX_DUPLICATES"
        echo "Current Rotations       : $TOTAL_ROTATIONS"
        echo "Current Saved IPs       : ${#IP_HISTORY[@]}"
        echo
        echo "0) Back"
        echo

        read -p "Choice: " settings_choice

        case "$settings_choice" in

            1)
                echo
                read -p "Enter new duplicate limit: " new_limit

                if [[ "$new_limit" =~ ^[0-9]+$ ]]; then
                    MAX_DUPLICATES="$new_limit"
                    echo
                    echo "[SUCCESS] Duplicate threshold updated."
                else
                    echo
                    echo "[ERROR] Invalid number."
                fi

                sleep 2
                ;;

            2)
                TOTAL_ROTATIONS=0
                IP_HISTORY=()
                DUPLICATE_COUNT=0

                echo
                echo "[SUCCESS] Session statistics reset."
                sleep 2
                ;;

            0)
                return
                ;;

            *)
                echo
                echo "[ERROR] Invalid choice."
                sleep 1
                ;;
        esac

    done
}

about_screen() {

    clear
    detect_platform
    detect_status

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║                     👻 GHOST ENGINE v5                           ║${RESET}"
    echo -e "${CYAN}║              Advanced TOR Privacy Framework                      ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${RESET}"
    echo

    echo -e "${GREEN}PROJECT INFORMATION${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Name        : Ghost Engine"
    echo -e "Version     : v5"
    echo -e "Developer   : Naboraj Sarkar (Nishant)"
    echo -e "Brand       : NS GAMING"
    echo -e "Platform    : $PLATFORM_NAME"
    echo

    echo -e "${GREEN}CURRENT ENGINE STATUS${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "TOR Status      : $TOR_STATUS"
    echo -e "Proxy Status    : $PROXY_STATUS"
    echo -e "Current Exit IP : $CURRENT_IP"
    echo -e "Proxy Endpoint  : ${PROXY_HOST}:${PRIVOXY_PORT}"
    echo

    echo -e "${GREEN}CORE FEATURES${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "✓ Automatic TOR Identity Rotation"
    echo -e "✓ Manual Identity Rotation"
    echo -e "✓ HTTP Proxy Support"
    echo -e "✓ SOCKS5 Proxy Support"
    echo -e "✓ Exit IP Monitoring"
    echo -e "✓ IP History Tracking"
    echo -e "✓ Duplicate IP Detection"
    echo -e "✓ Auto Engine Recovery"
    echo -e "✓ Documentation Center"
    echo -e "✓ Multi Platform Support"
    echo

    echo -e "${GREEN}SUPPORTED PLATFORMS${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "🐧 Linux"
    echo -e "🖥 WSL (Windows Subsystem for Linux)"
    echo -e "📱 Android Termux"
    echo -e "🍎 macOS"
    echo

    echo -e "${GREEN}HOW GHOST ENGINE WORKS${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Application"
    echo -e "     ↓"
    echo -e "  Privoxy"
    echo -e "     ↓"
    echo -e "    TOR"
    echo -e "     ↓"
    echo -e " Internet"
    echo
    echo -e "Traffic is routed through TOR before reaching"
    echo -e "its destination, helping improve privacy."
    echo

    echo -e "${GREEN}SECURITY NOTES${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "• Ghost Engine does not store browsing history."
    echo -e "• Session history exists only during runtime."
    echo -e "• TOR improves privacy but cannot guarantee anonymity."
    echo -e "• Logging into personal accounts can reveal identity."
    echo -e "• Always use common sense when browsing."
    echo

    echo -e "${GREEN}OPEN SOURCE${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "GitHub Repository:"
    echo -e "https://github.com/naborajs/Termux-Tor-IP-Rotator"
    echo

    echo -e "${DIM}Built for learning, privacy, networking and TOR research.${RESET}"
    echo
    read -p $'Press ENTER to return... ' _
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
        echo -e "${GREEN}║${RESET} 7 🛡 Verify TOR       8 ❤️ Project Info     9 ⚙ Settings                ${GREEN}║${RESET}"
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
                project_info
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
