#!/bin/bash

# ==========================================
# RedTeam Framework - Environment Setup
# ==========================================

echo "[*] Initializing RedTeam Shell Framework..."

# 1. Create Directories
mkdir -p modules logs docs tmp

# 2. Create Module Files (Empty placeholders)
touch modules/shells.sh
touch modules/encrypt.sh
touch modules/relay.sh
touch modules/transfer.sh
touch modules/upgrade.sh
touch modules/logger.sh

# 3. Create the Listener Module (with content)
cat <<EOF > modules/listeners.sh
#!/bin/bash

check_rlwrap() {
    if ! command -v rlwrap &> /dev/null; then
        echo -e "\${RED}[!] rlwrap is not installed.\${NC}"
        echo "    Install it with: sudo apt install rlwrap"
        return 1
    fi
    return 0
}

start_listener() {
    local port=\$1
    local use_rlwrap=\$2
    local timestamp=\$(date +%Y%m%d_%H%M%S)
    local logfile="logs/session_\${port}_\${timestamp}.log"

    echo -e "\${GREEN}[+] Starting Listener on Port \$port...\${NC}"
    echo -e "\${CYAN}[i] Logging session to: \$logfile\${NC}"
    echo -e "\${YELLOW}[!] Waiting for connection... (Press Ctrl+C to stop)\${NC}"
    
    if [ "\$use_rlwrap" == "yes" ]; then
        if check_rlwrap; then
            rlwrap -c -r nc -lvnp "\$port" | tee -a "\$logfile"
        else
            nc -lvnp "\$port" | tee -a "\$logfile"
        fi
    else
        nc -lvnp "\$port" | tee -a "\$logfile"
    fi
}

listener_menu() {
    echo -e "\${CYAN}--- Listener Menu ---\${NC}"
    echo "1. Standard Listener (nc)"
    echo "2. Smart Listener (rlwrap + nc)"
    echo "3. Back"
    echo ""
    read -p "Select > " l_choice

    case \$l_choice in
        1)
            read -p "Enter Port: " l_port
            start_listener "\$l_port" "no"
            ;;
        2)
            read -p "Enter Port: " l_port
            start_listener "\$l_port" "yes"
            ;;
        3) return ;;
        *) echo "Invalid option." ;;
    esac
}
EOF

# 4. Set Permissions
chmod +x modules/*.sh

echo "[+] Setup Complete! Run: ./shellmaster.sh"
