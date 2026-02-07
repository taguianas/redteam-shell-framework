#!/bin/bash

# ==========================================
# RedTeam Shell Framework - Main Controller
# ==========================================

# --- Configuration ---
MODULE_DIR="modules"
LOG_DIR="logs"

# --- Colors for Professional UI ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Self-Check & Initialization ---
# This ensures the script doesn't crash if setup_env.sh wasn't run
if [ ! -d "$MODULE_DIR" ]; then
    echo -e "${YELLOW}[!] First run detected. Initializing directories...${NC}"
    mkdir -p "$MODULE_DIR" "$LOG_DIR" "docs" "tmp"
fi

# Function to safely source modules
safe_source() {
    local file="$MODULE_DIR/$1"
    if [ -f "$file" ]; then
        source "$file"
    else
        # Create empty placeholder if missing to prevent "No such file" errors
        touch "$file"
    fi
}

# --- Import Modules ---
safe_source "listeners.sh"
safe_source "shells.sh"
safe_source "encrypt.sh"
safe_source "relay.sh"
safe_source "transfer.sh"
safe_source "upgrade.sh"
safe_source "logger.sh"

# --- UI Functions ---

print_banner() {
    clear
    echo -e "${RED}"
    echo "  ____  _          _ _ __  __           _            "
    echo " / ___|| |__   ___| | |  \/  | __ _ ___| |_ ___ _ __ "
    echo " \___ \| '_ \ / _ \ | | |\/| |/ _\` / __| __/ _ \ '__|"
    echo "  ___) | | | |  __/ | | |  | | (_| \__ \ ||  __/ |   "
    echo " |____/|_| |_|\___|_|_|_|  |_|\__,_|___/\__\___|_|   "
    echo -e "${NC}"
    echo -e "${BLUE}  :: RedTeam Shell Framework :: v1.0 ::${NC}"
    echo "-----------------------------------------------------"
}

# --- Logic Handling ---

handle_choice() {
    case $1 in
        1)
            # Calls function in modules/listeners.sh (Phase 1)
            echo -e "\n${GREEN}[+] Loading Listener Module...${NC}"
            sleep 0.5
            if type listener_menu &>/dev/null; then
                listener_menu
            else
                echo -e "${YELLOW}[!] Listener module error: function not found.${NC}"
            fi 
            ;;
        2)
            # Calls function in modules/shells.sh (Phase 2)
            # NOW ACTIVE
            echo -e "\n${GREEN}[+] Loading Payload Generator...${NC}"
            sleep 0.5
            if type payload_menu &>/dev/null; then
                payload_menu
            else
                echo -e "${YELLOW}[!] Payload module error: function not found.${NC}"
                echo -e "    Make sure modules/shells.sh is populated."
            fi
            ;;
        3)
            # PHASE 3 NOW ACTIVE
            echo -e "\n${GREEN}[+] Loading Encryption Module...${NC}"
            sleep 0.5
            if type encrypt_menu &>/dev/null; then 
                encrypt_menu 
            else 
                echo -e "${YELLOW}Error: encrypt_menu not found. Check modules/encrypt.sh${NC}"
            fi
            ;;
        4)
            echo -e "\n${GREEN}[+] Loading Transfer Module...${NC}"
            echo -e "${YELLOW}[!] Module under construction (Phase 4)${NC}"
            ;;
        5)
            echo -e "\n${GREEN}[+] Loading Relay Module...${NC}"
            echo -e "${YELLOW}[!] Module under construction (Phase 5)${NC}"
            ;;
        6)
            echo -e "\n${GREEN}[+] Loading PTY Upgrade Tools...${NC}"
            echo -e "${YELLOW}[!] Module under construction (Phase 6)${NC}"
            ;;
        99)
            echo -e "\n${RED}[!] Exiting Framework.${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}[!] Invalid Option. Please try again.${NC}"
            sleep 1
            ;;
    esac
}

main_menu() {
    print_banner
    echo -e "${YELLOW}[ Phase 1: Core Listeners ]${NC}"
    echo "1. Start Listener (nc/rlwrap)"
    echo ""
    echo -e "${YELLOW}[ Phase 2: Payloads ]${NC}"
    echo "2. Generate Reverse Shell Payload"
    echo ""
    echo -e "${YELLOW}[ Phase 3: Encryption ]${NC}"
    echo "3. Start Encrypted Listener (socat/ncat)"
    echo ""
    echo -e "${YELLOW}[ Phase 4-6: Advanced Operations ]${NC}"
    echo "4. File Transfer"
    echo "5. Pivot / Relay"
    echo "6. Shell Stabilization (PTY)"
    echo ""
    echo -e "${RED}99. Exit${NC}"
    echo "-----------------------------------------------------"
    read -p "Select an option > " choice
    handle_choice $choice
}

# --- Main Loop ---
while true; do
    main_menu
    echo -e "\nPress [ENTER] to return to menu..."
    read
done
