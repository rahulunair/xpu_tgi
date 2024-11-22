#!/usr/bin/env bash

# Strict error handling
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config/model.env"

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

cleanup() {
    local exit_code=$?
    
    # Stop containers using docker-compose
    log "Stopping containers..."
    docker compose -f "${SCRIPT_DIR}/docker-compose.yml" down --timeout 30
    
    # Ensure container is removed even if compose down fails
    if docker ps -a --format '{{.Names}}' | grep -q "^${MODEL_NAME}$"; then
        log "Forcing container removal..."
        docker rm -f "${MODEL_NAME}" || true
    fi
    
    # Remove network if it exists
    if docker network ls --format '{{.Name}}' | grep -q "^${MODEL_NAME}_network$"; then
        log "Removing network..."
        docker network rm "${MODEL_NAME}_network" || true
    fi
    
    # Check and kill any process using the port
    local pid
    pid=$(lsof -ti:${PORT} 2>/dev/null || true)
    if [[ -n "${pid}" ]]; then
        log "Killing process using port ${PORT}..."
        kill -9 "${pid}" 2>/dev/null || true
    fi
    
    log "Cleanup completed"
    exit $exit_code
}

# Set cleanup trap
trap cleanup EXIT

log "Stopping Qwen-7B service..."
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" --env-file "${SCRIPT_DIR}/config/model.env" down

log "Service stopped successfully" 