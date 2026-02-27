#!/bin/bash
################################################################################
# Config - Global configuration and environment setup
################################################################################

# Framework version
export VERSION="0.1.0"
export FRAMEWORK_NAME="Red Team Shell Framework"

# Directory structure
export FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CORE_DIR="${FRAMEWORK_DIR}/core"
export MODULES_DIR="${FRAMEWORK_DIR}/modules"
export LOGS_DIR="${FRAMEWORK_DIR}/logs"
export CERTS_DIR="${FRAMEWORK_DIR}/certs"
export PAYLOADS_DIR="${FRAMEWORK_DIR}/payloads"

# Create necessary directories
mkdir -p "${LOGS_DIR}"
mkdir -p "${CERTS_DIR}"
mkdir -p "${PAYLOADS_DIR}"

# Logging configuration
export LOG_FILE="${LOGS_DIR}/framework.log"
export LOG_LEVEL="${LOG_LEVEL:-INFO}"  # DEBUG, INFO, WARN, ERROR
export LOG_FORMAT="json"  # Structured JSON logging

# Session configuration
export SESSION_DIR="${LOGS_DIR}/sessions"
export SESSION_PREFIX="shell_"
export SESSION_TIMEOUT=3600  # 1 hour

# Encryption defaults
export DEFAULT_CIPHER="aes-256-cbc"
export KEY_SIZE=2048
export CERT_VALIDITY=365

# Transfer configuration
export TRANSFER_CHUNK_SIZE=$((1024 * 1024))  # 1MB chunks
export TRANSFER_TIMEOUT=300

# CLI configuration
export CLI_COLORS=true
export CLI_SPINNER=true

# Load local overrides if they exist
if [[ -f "${FRAMEWORK_DIR}/.env" ]]; then
    source "${FRAMEWORK_DIR}/.env"
fi

# Validate required tools
check_requirements() {
    local required_tools=("bash" "nc" "openssl")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo "ERROR: Missing required tools: ${missing_tools[*]}" >&2
        return 1
    fi
    return 0
}

# Initialize framework
init_framework() {
    mkdir -p "${LOGS_DIR}/sessions"
    mkdir -p "${CERTS_DIR}"
    mkdir -p "${PAYLOADS_DIR}"
    touch "${LOG_FILE}"
}

# Call initialization
init_framework
