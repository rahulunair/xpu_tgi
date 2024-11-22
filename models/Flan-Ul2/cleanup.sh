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

cleanup() {
    local exit_code=$?

    log "Starting cleanup process..."

    # 1. Stop and remove containers using docker-compose
    if [[ -f "${SCRIPT_DIR}/docker-compose.yml" ]]; then
        log "Stopping containers using docker-compose..."
        docker compose -f "${SCRIPT_DIR}/docker-compose.yml" down --timeout 30 || true
    fi

    # 2. Force remove container if it still exists
    local container_name="${MODEL_NAME:-flan-ul2-tgi}"
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log "Force removing container ${container_name}..."
        docker rm -f "${container_name}" || true
    fi

    # 3. Remove network
    local network_name="${MODEL_NAME:-flan-ul2-tgi}_network"
    if docker network ls --format '{{.Name}}' | grep -q "^${network_name}$"; then
        log "Removing network ${network_name}..."
        docker network rm "${network_name}" || true
    fi

    # 4. Clean up port usage
    local port="${PORT:-8083}"
    local pid
    pid=$(lsof -ti:"${port}" 2>/dev/null || true)
    if [[ -n "${pid}" ]]; then
        log "Cleaning up process using port ${port}..."
        kill -9 "${pid}" 2>/dev/null || true
    fi

    log "Cleanup completed"
    return $exit_code
}

# Run cleanup if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    cleanup
fi
