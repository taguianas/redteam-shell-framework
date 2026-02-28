#!/bin/bash
################################################################################
# Config - Global configuration and environment setup
################################################################################

# Framework version
export VERSION="1.0.0"
export FRAMEWORK_NAME="Red Team Shell Framework"

# Directory structure
export FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export MODULES_DIR="${FRAMEWORK_DIR}/modules"
export LOGS_DIR="${FRAMEWORK_DIR}/logs"
export CERTS_DIR="${FRAMEWORK_DIR}/certs"
export PAYLOADS_DIR="${FRAMEWORK_DIR}/payloads"

# Logging configuration
export LOG_FILE="${LOGS_DIR}/framework.log"
export LOG_LEVEL="${LOG_LEVEL:-INFO}"  # DEBUG, INFO, WARN, ERROR

# Session configuration
export SESSION_DIR="${LOGS_DIR}/sessions"
export SESSION_PREFIX="shell_"
export SESSION_TIMEOUT=3600  # 1 hour

# Encryption defaults
export DEFAULT_CIPHER="aes-256-cbc"
export KEY_SIZE=2048
export CERT_VALIDITY=365

# CLI configuration
export CLI_COLORS=true

# Load local overrides if they exist
if [[ -f "${FRAMEWORK_DIR}/.env" ]]; then
    source "${FRAMEWORK_DIR}/.env"
fi

# Initialize framework directories and log file
init_framework() {
    mkdir -p "${LOGS_DIR}/sessions"
    mkdir -p "${CERTS_DIR}"
    mkdir -p "${PAYLOADS_DIR}"
    touch "${LOG_FILE}"
}

init_framework
