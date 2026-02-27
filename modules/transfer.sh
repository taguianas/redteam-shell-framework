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
        echo "3. Verify Checksum"
        echo "4. View History"
        echo "5. Back"
        echo ""
        read -p "Select: " choice
        
        case "$choice" in
            1) upload_file ;;
            2) download_file ;;
            3) verify_checksum ;;
            4) view_transfer_history ;;
            5) break ;;
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
    else
        echo ""
        echo "Download failed."
    fi
    sleep 2
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
        history=$(grep -i "transfer\|upload\|download\|scp" "${LOG_FILE}" 2>/dev/null | tail -20)
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


