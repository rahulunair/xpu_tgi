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

cleanup() {
    local exit_code=$?

    log "Starting cleanup process..."

    # 1. Stop and remove containers using docker-compose
    if [[ -f "${SCRIPT_DIR}/docker-compose.yml" ]]; then
        log "Stopping containers using docker-compose..."
        docker compose -f "${SCRIPT_DIR}/docker-compose.yml" --env-file "${ENV_FILE}" down --timeout 30 || true
    fi

    # 2. Force remove container if it still exists
    local container_name="${MODEL_NAME}"
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log "Force removing container ${container_name}..."
        docker rm -f "${container_name}" || true
    fi

    # 3. Remove network
    local network_name="tgi_${MODEL_NAME}_network"
    if docker network ls --format '{{.Name}}' | grep -q "^${network_name}$"; then
        log "Removing network ${network_name}..."
        docker network rm "${network_name}" || true
    fi

    # 4. Clean up port usage
    local port="${PORT}"
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
