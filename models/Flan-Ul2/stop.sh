#!/usr/bin/env bash

# Strict error handling
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables
ENV_FILE="${SCRIPT_DIR}/config/model.env"
if [[ ! -f "${ENV_FILE}" ]]; then
    log "ERROR: model.env file not found at ${ENV_FILE}"
    exit 1
fi

# Export all variables from env file
set -a
source "${ENV_FILE}"
set +a

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Error handler
error_handler() {
    local line_no=$1
    local error_code=$2
    log "ERROR: Command failed at line ${line_no} with exit code ${error_code}"
    exit "${error_code}"
}

# Set error handler
trap 'error_handler ${LINENO} $?' ERR

# Check if running as systemd service
SERVICE_NAME="${MODEL_NAME:-flan-ul2-tgi}"
if systemctl is-active --quiet "${SERVICE_NAME}"; then
    log "Stopping systemd service ${SERVICE_NAME}..."
    if [ "$EUID" -ne 0 ]; then
        log "ERROR: Please run with sudo to stop systemd service"
        exit 1
    fi
    systemctl stop "${SERVICE_NAME}" || true
    systemctl disable "${SERVICE_NAME}" || true
    rm -f "/etc/systemd/system/${SERVICE_NAME}.service" || true
    systemctl daemon-reload
    log "Systemd service ${SERVICE_NAME} stopped and disabled"
fi

# Run cleanup script
log "Running cleanup process..."
source "${SCRIPT_DIR}/cleanup.sh"

log "Service stopped successfully"
