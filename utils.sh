#!/bin/bash
################################################################################
# Utils - Common utilities, logging, and helper functions
################################################################################

################################################################################
# Colors and formatting
################################################################################

color_red() {
    if [[ "${CLI_COLORS:-true}" == "true" ]]; then
        echo -e "\033[0;31m${1}\033[0m"
    else
        echo "$1"
    fi
}

color_green() {
    if [[ "${CLI_COLORS:-true}" == "true" ]]; then
        echo -e "\033[0;32m${1}\033[0m"
    else
        echo "$1"
    fi
}

color_yellow() {
    if [[ "${CLI_COLORS:-true}" == "true" ]]; then
        echo -e "\033[1;33m${1}\033[0m"
    else
        echo "$1"
    fi
}

color_cyan() {
    if [[ "${CLI_COLORS:-true}" == "true" ]]; then
        echo -e "\033[0;36m${1}\033[0m"
    else
        echo "$1"
    fi
}

color_blue() {
    if [[ "${CLI_COLORS:-true}" == "true" ]]; then
        echo -e "\033[0;34m${1}\033[0m"
    else
        echo "$1"
    fi
}

################################################################################
# Message functions
################################################################################

success_msg() {
    echo "$(color_green '✓')" "$1"
}

error_msg() {
    echo "$(color_red '✗')" "$1" >&2
}

warn_msg() {
    echo "$(color_yellow '⚠')" "$1"
}

info_msg() {
    echo "$(color_cyan 'ℹ')" "$1"
}

################################################################################
# Logging functions
################################################################################

log_to_json() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local user="${SUDO_USER:-$USER}"
    
    local json_log="{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"$message\",\"user\":\"$user\",\"pid\":$$}"
    
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "$json_log" >> "${LOG_FILE}" 2>/dev/null || true
    fi
}

log_debug() {
    [[ "${LOG_LEVEL}" == "DEBUG" ]] && log_to_json "DEBUG" "$1"
}

log_info() {
    [[ "${LOG_LEVEL}" =~ ^(DEBUG|INFO)$ ]] && log_to_json "INFO" "$1"
}

log_warn() {
    [[ "${LOG_LEVEL}" =~ ^(DEBUG|INFO|WARN)$ ]] && log_to_json "WARN" "$1"
}

log_error() {
    log_to_json "ERROR" "$1"
}

################################################################################
# Session management
################################################################################

# Generate unique session ID
generate_session_id() {
    echo "${SESSION_PREFIX}$(date +%s)_${RANDOM}"
}

# Create session tracking file
create_session() {
    local session_id="$1"
    local local_ip="${2:-127.0.0.1}"
    local local_port="${3:-0}"
    local remote_ip="${4:-0.0.0.0}"
    local remote_port="${5:-0}"
    
    local session_file="${SESSION_DIR}/${session_id}.json"
    mkdir -p "${SESSION_DIR}"
    
    local session_data="{\"session_id\":\"$session_id\",\"created_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",\"local_ip\":\"$local_ip\",\"local_port\":$local_port,\"remote_ip\":\"$remote_ip\",\"remote_port\":$remote_port,\"status\":\"active\",\"user\":\"${SUDO_USER:-$USER}\"}"
    
    echo "$session_data" > "$session_file"
    log_info "Created session: $session_id"
    echo "$session_id"
}

# Log session event
log_session() {
    local session_id="$1"
    local event="$2"
    local data="${3:-}"
    
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local log_entry="{\"timestamp\":\"$timestamp\",\"session_id\":\"$session_id\",\"event\":\"$event\",\"data\":\"$data\",\"user\":\"${SUDO_USER:-$USER}\"}"
    
    local session_log="${SESSION_DIR}/${session_id}.log"
    mkdir -p "${SESSION_DIR}"
    echo "$log_entry" >> "$session_log" 2>/dev/null || true
}

# List all active sessions
list_sessions() {
    echo ""
    echo "$(color_cyan '═══ ACTIVE SESSIONS ═══')"
    echo ""
    
    if [[ ! -d "${SESSION_DIR}" ]] || [[ -z $(ls -1 "${SESSION_DIR}" 2>/dev/null | grep '.json') ]]; then
        info_msg "No active sessions"
        echo ""
        return 1
    fi
    
    printf "%-30s %-25s %-20s %-15s %s\n" "SESSION ID" "CREATED" "LOCAL:REMOTE" "STATUS" "USER"
    printf "%s\n" "$(echo '─────────────────────────────────────────────────────────────────────────────────')"
    
    for session_file in "${SESSION_DIR}"/*.json; do
        if [[ -f "$session_file" ]]; then
            local session_id=$(basename "$session_file" .json)
            local created=$(grep -o '"created_at":"[^"]*' "$session_file" 2>/dev/null | cut -d'"' -f4)
            local local_ip=$(grep -o '"local_ip":"[^"]*' "$session_file" 2>/dev/null | cut -d'"' -f4)
            local local_port=$(grep -o '"local_port":[0-9]*' "$session_file" 2>/dev/null | cut -d':' -f2)
            local remote_ip=$(grep -o '"remote_ip":"[^"]*' "$session_file" 2>/dev/null | cut -d'"' -f4)
            local remote_port=$(grep -o '"remote_port":[0-9]*' "$session_file" 2>/dev/null | cut -d':' -f2)
            local status=$(grep -o '"status":"[^"]*' "$session_file" 2>/dev/null | cut -d'"' -f4)
            local user=$(grep -o '"user":"[^"]*' "$session_file" 2>/dev/null | cut -d'"' -f4)
            
            local local_addr="${local_ip}:${local_port}"
            local remote_addr="${remote_ip}:${remote_port}"
            
            printf "%-30s %-25s %-20s %-15s %s\n" \
                "${session_id:0:30}" \
                "${created:5:19}" \
                "$local_addr" \
                "$(color_green "$status")" \
                "${user:0:15}"
        fi
    done
    echo ""
}

################################################################################
# Input validation
################################################################################

validate_ip() {
    local ip="$1"
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_port() {
    local port="$1"
    if [[ $port =~ ^[0-9]+$ ]] && ((port >= 1 && port <= 65535)); then
        return 0
    else
        return 1
    fi
}

################################################################################
# IP detection
################################################################################

get_local_ip() {
    local ip
    # Try ip route (Linux)
    ip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K[^\s]+' | head -1)
    # Fallback: hostname -I
    if [[ -z "$ip" ]]; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    # Fallback: ifconfig
    if [[ -z "$ip" ]]; then
        ip=$(ifconfig 2>/dev/null | grep -oP 'inet \K[0-9.]+' | grep -v '127.0.0.1' | head -1)
    fi
    echo "${ip:-127.0.0.1}"
}

prompt_local_ip() {
    local detected
    detected=$(get_local_ip)
    echo -n "Attacker IP [${detected}]: " >&2
    local ip
    read -r ip
    echo "${ip:-$detected}"
}

################################################################################
# Session notes
################################################################################

add_session_note() {
    local session_id="$1"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local notes_file="${SESSION_DIR}/${session_id}.notes"
    mkdir -p "${SESSION_DIR}"
    echo -n "Note: "
    local note
    read -r note
    if [[ -n "$note" ]]; then
        echo "[${timestamp}] ${note}" >> "$notes_file"
        success_msg "Note saved."
    else
        warn_msg "Empty note, nothing saved."
    fi
}

view_session_notes() {
    local session_id="$1"
    local notes_file="${SESSION_DIR}/${session_id}.notes"
    echo ""
    echo "$(color_cyan "═══ NOTES: ${session_id} ═══")"
    echo ""
    if [[ -f "$notes_file" ]]; then
        cat "$notes_file"
    else
        info_msg "No notes for this session."
    fi
    echo ""
    sleep 2
}

session_notes_menu() {
    echo ""
    echo "$(color_cyan '═══ SESSION NOTES ═══')"
    echo ""
    if [[ ! -d "${SESSION_DIR}" ]] || [[ -z $(ls -1 "${SESSION_DIR}" 2>/dev/null | grep '.json$') ]]; then
        info_msg "No sessions found."
        echo ""
        sleep 2
        return
    fi

    echo "Available sessions:"
    echo ""
    local i=1
    local -a session_ids
    for f in "${SESSION_DIR}"/*.json; do
        [[ -f "$f" ]] || continue
        local sid
        sid=$(basename "$f" .json)
        session_ids+=("$sid")
        echo "  $i. $sid"
        (( i++ ))
    done
    echo ""
    echo -n "Select session number (or 0 to cancel): "
    local sel
    read -r sel
    if [[ ! "$sel" =~ ^[0-9]+$ ]] || (( sel == 0 )) || (( sel > ${#session_ids[@]} )); then
        return
    fi
    local chosen="${session_ids[$((sel-1))]}"

    echo ""
    echo "  1. Add note"
    echo "  2. View notes"
    echo -n "Select: "
    local action
    read -r action
    case "$action" in
        1) add_session_note "$chosen" ;;
        2) view_session_notes "$chosen" ;;
    esac
}

################################################################################
# File operations
################################################################################

ensure_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        touch "$file"
        log_debug "Created file: $file"
    fi
}

ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_debug "Created directory: $dir"
    fi
}

