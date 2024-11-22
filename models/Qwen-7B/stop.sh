#!/usr/bin/env bash

# Strict error handling
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Source cleanup script
log "Stopping service and cleaning up..."
if ! source "${SCRIPT_DIR}/scripts/cleanup.sh"; then
    log "ERROR: Cleanup failed"
    exit 1
fi

log "Service stopped successfully" 