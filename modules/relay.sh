#!/bin/bash

################################################################################
# Relay Module - Pivoting and Port Forwarding
################################################################################

relay_menu() {
    while true; do
        clear
        echo ""
        echo "RELAY & PIVOT MENU"
        echo "1. Create Socat Relay"
        echo "2. Create SSH Tunnel"
        echo "3. List Active Relays"
        echo "4. Stop Relay"
        echo "5. Back"
        echo ""
        read -p "Select: " choice
        
        case "$choice" in
            1) create_socat_relay ;;
            2) create_ssh_tunnel ;;
            3) list_active_relays ;;
            4) stop_relay ;;
            5) break ;;
            *) echo "Invalid"; sleep 1 ;;
        esac
    done
}

create_socat_relay() {
    echo ""
    echo "=== CREATE SOCAT RELAY ==="
    echo ""

    if ! command -v socat &>/dev/null; then
        echo "Error: socat is not installed. Install with: apt install socat"
        sleep 3
        return 1
    fi

    echo -n "Listen port (local): "
    read -r listen_port
    echo -n "Forward to host: "
    read -r forward_host
    echo -n "Forward to port: "
    read -r forward_port

    if [[ -z "$listen_port" || -z "$forward_host" || -z "$forward_port" ]]; then
        echo "Error: All fields required."
        sleep 2
        return 1
    fi

    echo ""
    echo "Starting relay: 0.0.0.0:${listen_port} → ${forward_host}:${forward_port}"
    socat TCP-LISTEN:"${listen_port}",fork,reuseaddr TCP:"${forward_host}":"${forward_port}" &
    local pid=$!

    echo "Relay started (PID: $pid)"
    echo "To stop: kill $pid"
    sleep 3
}

create_ssh_tunnel() {
    echo ""
    echo "=== CREATE SSH TUNNEL ==="
    echo ""
    echo "  1. Local port forward   (-L  local_port:remote_host:remote_port)"
    echo "  2. Remote port forward  (-R  remote_port:local_host:local_port)"
    echo "  3. Dynamic SOCKS proxy  (-D  socks_port)"
    echo ""
    read -p "Select tunnel type: " tunnel_type

    case "$tunnel_type" in
        1)
            echo -n "SSH user@host: "
            read -r ssh_target
            echo -n "Local port: "
            read -r local_port
            echo -n "Remote host to reach: "
            read -r remote_host
            echo -n "Remote port: "
            read -r remote_port
            echo ""
            echo "Command: ssh -L ${local_port}:${remote_host}:${remote_port} ${ssh_target} -N -f"
            ssh -L "${local_port}:${remote_host}:${remote_port}" "${ssh_target}" -N -f
            [[ $? -eq 0 ]] && echo "Tunnel started." || echo "Tunnel failed."
            ;;
        2)
            echo -n "SSH user@host: "
            read -r ssh_target
            echo -n "Remote port (on SSH server): "
            read -r remote_port
            echo -n "Local host [127.0.0.1]: "
            read -r local_host
            local_host="${local_host:-127.0.0.1}"
            echo -n "Local port: "
            read -r local_port
            echo ""
            echo "Command: ssh -R ${remote_port}:${local_host}:${local_port} ${ssh_target} -N -f"
            ssh -R "${remote_port}:${local_host}:${local_port}" "${ssh_target}" -N -f
            [[ $? -eq 0 ]] && echo "Tunnel started." || echo "Tunnel failed."
            ;;
        3)
            echo -n "SSH user@host: "
            read -r ssh_target
            echo -n "SOCKS port [1080]: "
            read -r socks_port
            socks_port="${socks_port:-1080}"
            echo ""
            echo "Command: ssh -D ${socks_port} ${ssh_target} -N -f"
            ssh -D "${socks_port}" "${ssh_target}" -N -f
            [[ $? -eq 0 ]] && echo "SOCKS proxy started on port ${socks_port}." || echo "Failed."
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
    sleep 2
}

list_active_relays() {
    echo ""
    echo "=== ACTIVE RELAYS & TUNNELS ==="
    echo ""

    local results
    results=$(ps aux | grep -E '[s]ocat|[s]sh.*-[NfLRD]' | grep -v grep)

    if [[ -z "$results" ]]; then
        echo "No active relays or tunnels found."
    else
        printf "%-8s %-10s %s\n" "PID" "USER" "COMMAND"
        printf "%s\n" "------------------------------------------------------------"
        echo "$results" | awk '{printf "%-8s %-10s %s\n", $2, $1, substr($0, index($0,$11))}'
    fi
    echo ""
    sleep 3
}

stop_relay() {
    echo ""
    echo "=== STOP RELAY / TUNNEL ==="
    echo ""

    list_active_relays

    echo -n "Enter PID to stop: "
    read -r pid

    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        echo "Invalid PID."
        sleep 2
        return 1
    fi

    if kill "$pid" 2>/dev/null; then
        echo "Process $pid stopped."
    else
        echo "Failed to stop PID $pid — not found or no permission."
    fi
    sleep 2
}


