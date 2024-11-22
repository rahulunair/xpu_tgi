#!/usr/bin/env bash

# Strict error handling
set -euo pipefail
IFS=$'\n\t'

# Script variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config/model.env"
MAX_WAIT=300  # Maximum wait time in seconds for health check
INTERVAL=10   # Check interval in seconds

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

# Check if docker compose is available
if ! command -v docker compose &> /dev/null; then
    log "ERROR: docker compose is not installed"
    exit 1
fi

# Validate network before starting
validate_network() {
    local network_name="${MODEL_NAME}_network"
    
    # Check if network already exists
    if docker network ls --format '{{.Name}}' | grep -q "^${network_name}$"; then
        log "Network ${network_name} already exists, checking for conflicts..."
        
        # Check for any containers using this network
        local connected_containers
        connected_containers=$(docker network inspect "${network_name}" -f '{{range .Containers}}{{.Name}} {{end}}')
        if [[ -n "${connected_containers}" ]]; then
            log "WARNING: Network ${network_name} is being used by: ${connected_containers}"
            log "Cleaning up network..."
            docker compose -f "${SCRIPT_DIR}/docker-compose.yml" down --remove-orphans
        fi
    fi
}

# Validate network before starting
validate_network

# Start the service
log "Starting Qwen-7B service..."
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" --env-file "${SCRIPT_DIR}/config/model.env" up -d

# Wait for service to be healthy
log "Waiting for service to be healthy..."
elapsed=0
while [ $elapsed -lt $MAX_WAIT ]; do
    if docker compose -f "${SCRIPT_DIR}/docker-compose.yml" ps --format json | grep -q '"Health": "healthy"'; then
        log "Service is healthy"
        docker compose -f "${SCRIPT_DIR}/docker-compose.yml" ps
        exit 0
    fi
    sleep $INTERVAL
    elapsed=$((elapsed + INTERVAL))
    log "Still waiting for service to be healthy... ($elapsed/${MAX_WAIT}s)"
done

log "ERROR: Service failed to become healthy within ${MAX_WAIT} seconds"
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" logs
exit 1