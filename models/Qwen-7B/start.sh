#!/usr/bin/env bash

# Strict error handling
set -euo pipefail
IFS=$'\n\t'

# Script variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAX_WAIT=300
INTERVAL=10

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Error handler
error_handler() {
    local line_no=$1
    local error_code=$2
    log "ERROR: Command failed at line ${line_no} with exit code ${error_code}"
    docker compose -f "${SCRIPT_DIR}/docker-compose.yml" logs
    exit "${error_code}"
}

# Set error handler
trap 'error_handler ${LINENO} $?' ERR

# Load and export environment variables
ENV_FILE="${SCRIPT_DIR}/config/model.env"
if [[ ! -f "${ENV_FILE}" ]]; then
    log "ERROR: model.env file not found at ${ENV_FILE}"
    exit 1
fi

# Export all variables from env file
set -a
source "${ENV_FILE}"
set +a

# Validate network before starting
validate_network() {
    local network_name="${MODEL_NAME:-qwen-7b-tgi}_network"
    
    log "Validating network configuration..."
    if docker network ls --format '{{.Name}}' | grep -q "^${network_name}$"; then
        log "Network ${network_name} exists, checking for conflicts..."
        
        local connected_containers
        connected_containers=$(docker network inspect "${network_name}" -f '{{range .Containers}}{{.Name}} {{end}}')
        if [[ -n "${connected_containers}" ]]; then
            log "WARNING: Network ${network_name} is being used by: ${connected_containers}"
            log "Cleaning up existing network..."
            docker compose -f "${SCRIPT_DIR}/docker-compose.yml" down --remove-orphans
        fi
    fi
}

# Debug: Print variables
log "Using configuration:"
log "MODEL_NAME: ${MODEL_NAME:-qwen-7b-tgi}"
log "PORT: ${PORT:-8083}"
log "SHM_SIZE: ${SHM_SIZE:-16g}"

# Validate network
validate_network

# Start the service
log "Starting Qwen-7B service..."
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" up -d

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