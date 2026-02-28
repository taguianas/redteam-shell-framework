#!/bin/bash

################################################################################
# Transfer Module - File upload/download
################################################################################

transfer_menu() {
    while true; do
        clear
        echo ""
        echo "TRANSFER MENU"
        echo "1. Upload File (SCP)"
        echo "2. Download File (SCP)"
        echo "3. Serve Files (HTTP Server)"
        echo "4. Verify Checksum"
        echo "5. View History"
        echo "6. Back"
        echo ""
        read -p "Select: " choice

        case "$choice" in
            1) upload_file ;;
            2) download_file ;;
            3) serve_http ;;
            4) verify_checksum ;;
            5) view_transfer_history ;;
            6) break ;;
            *) echo "Invalid"; sleep 1 ;;
        esac
    done
}

upload_file() {
    echo ""
    echo "=== UPLOAD FILE (SCP) ==="
    echo ""
    echo -n "Local file path: "
    read -r local_file

    if [[ ! -f "$local_file" ]]; then
        echo "Error: File not found: $local_file"
        sleep 2
        return 1
    fi

    echo -n "Remote user: "
    read -r remote_user
    echo -n "Remote host/IP: "
    read -r remote_host
    echo -n "Remote destination path [/tmp/]: "
    read -r remote_path
    remote_path="${remote_path:-/tmp/}"

    echo ""
    echo "Uploading: $local_file → ${remote_user}@${remote_host}:${remote_path}"
    echo ""
    scp "$local_file" "${remote_user}@${remote_host}:${remote_path}"

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Upload successful."
        log_info "SCP upload: $local_file → ${remote_user}@${remote_host}:${remote_path}"
    else
        echo ""
        echo "Upload failed."
    fi
    sleep 2
}

download_file() {
    echo ""
    echo "=== DOWNLOAD FILE (SCP) ==="
    echo ""
    echo -n "Remote user: "
    read -r remote_user
    echo -n "Remote host/IP: "
    read -r remote_host
    echo -n "Remote file path: "
    read -r remote_file
    echo -n "Local save path [./]: "
    read -r local_path
    local_path="${local_path:-./}"

    echo ""
    echo "Downloading: ${remote_user}@${remote_host}:${remote_file} → ${local_path}"
    echo ""
    scp "${remote_user}@${remote_host}:${remote_file}" "$local_path"

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Download successful."
        log_info "SCP download: ${remote_user}@${remote_host}:${remote_file} → ${local_path}"
    else
        echo ""
        echo "Download failed."
    fi
    sleep 2
}

serve_http() {
    echo ""
    echo "=== HTTP FILE SERVER ==="
    echo ""

    if ! command -v python3 &>/dev/null; then
        echo "Error: python3 not found. Install python3 to use this feature."
        sleep 3
        return 1
    fi

    echo -n "Directory to serve [./]: "
    local serve_dir
    read -r serve_dir
    serve_dir="${serve_dir:-./}"

    if [[ ! -d "$serve_dir" ]]; then
        echo "Error: Directory not found: $serve_dir"
        sleep 2
        return 1
    fi

    echo -n "Port [8000]: "
    local serve_port
    read -r serve_port
    serve_port="${serve_port:-8000}"

    if ! validate_port "$serve_port"; then
        echo "Error: Invalid port"
        sleep 2
        return 1
    fi

    local detected_ip
    detected_ip=$(get_local_ip)

    echo ""
    echo "Serving: $serve_dir"
    echo ""
    echo "Download files from target with:"
    echo "  wget http://${detected_ip}:${serve_port}/filename"
    echo "  curl http://${detected_ip}:${serve_port}/filename -O filename"
    echo ""
    echo "Press Ctrl+C to stop the server."
    echo ""

    log_info "HTTP server started on ${detected_ip}:${serve_port} serving ${serve_dir}"

    cd "$serve_dir" && python3 -m http.server "$serve_port"
}

verify_checksum() {
    echo ""
    echo "=== VERIFY CHECKSUM ==="
    echo ""
    echo -n "File path: "
    read -r file_path

    if [[ ! -f "$file_path" ]]; then
        echo "Error: File not found: $file_path"
        sleep 2
        return 1
    fi

    echo ""
    echo "MD5:    $(md5sum "$file_path" 2>/dev/null || md5 "$file_path" 2>/dev/null || echo 'md5 not available')"
    echo "SHA256: $(sha256sum "$file_path" 2>/dev/null || shasum -a 256 "$file_path" 2>/dev/null || echo 'sha256 not available')"
    echo ""
    sleep 3
}

view_transfer_history() {
    echo ""
    echo "=== TRANSFER HISTORY ==="
    echo ""

    if [[ -f "${LOG_FILE}" ]]; then
        local history
        history=$(grep -i "transfer\|upload\|download\|scp\|http server" "${LOG_FILE}" 2>/dev/null | tail -20)
        if [[ -n "$history" ]]; then
            echo "$history"
        else
            echo "No transfer events in log."
        fi
    else
        echo "No log file found."
    fi
    echo ""
    sleep 3
}
