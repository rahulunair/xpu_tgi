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
if ! docker compose -f "${SCRIPT_DIR}/docker-compose.yml" ps --format json > /dev/null 2>&1; then
    log "Service is not running"
    exit 1
fi

# Show service status
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" ps

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
docker stats --no-stream $(docker compose -f "${SCRIPT_DIR}/docker-compose.yml" ps -q)

# Show recent logs
log "Recent logs:"
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" logs --tail=20 