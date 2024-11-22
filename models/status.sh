#!/usr/bin/env bash

# Strict error handling
set -euo pipefail
IFS=$'\n\t'

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <model_directory>"
    echo "Example: $0 Flan-Ul2"
    exit 1
fi

# Script variables
MODEL_DIR="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables
ENV_FILE="${SCRIPT_DIR}/${MODEL_DIR}/config/model.env"
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

check_network_status() {
    local network_name="${MODEL_NAME}_network"

    log "Checking network status..."
    if docker network ls --format '{{.Name}}' | grep -q "^${network_name}$"; then
        log "Network ${network_name} exists"

        # Check network details
        log "Network details:"
        docker network inspect "${network_name}" -f '
Network ID: {{.Id}}
Name: {{.Name}}
Driver: {{.Driver}}
Containers connected: {{range .Containers}}
  - {{.Name}} ({{.IPv4Address}}){{end}}'
    else
        log "WARNING: Network ${network_name} does not exist"
        return 1
    fi
}

# Check service status
log "Checking service status..."
if ! docker compose -f "${SCRIPT_DIR}/docker-compose.yml" --env-file "${ENV_FILE}" ps --format json > /dev/null 2>&1; then
    log "Service is not running"
    exit 1
fi

# Show service status
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" --env-file "${ENV_FILE}" ps

# Check network status
check_network_status

# Check port availability
if netstat -tuln | grep -q ":${PORT} "; then
    log "Port ${PORT} is listening"
else
    log "WARNING: Port ${PORT} is not listening"
fi

# Show resource usage
log "Resource usage:"
docker stats --no-stream $(docker compose -f "${SCRIPT_DIR}/docker-compose.yml" --env-file "${ENV_FILE}" ps -q)

# Show recent logs
log "Recent logs:"
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" --env-file "${ENV_FILE}" logs --tail=20
