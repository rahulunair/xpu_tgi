#!/bin/bash

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (with sudo)"
    exit 1
fi

SERVICE_NAME=$(basename "$(pwd)")

log "Stopping service ${SERVICE_NAME}..."
systemctl stop "$SERVICE_NAME" || { echo "Failed to stop $SERVICE_NAME"; exit 1; }
log "Disabling service ${SERVICE_NAME}..."
systemctl disable "$SERVICE_NAME" || { echo "Failed to disable $SERVICE_NAME"; exit 1; }
log "Removing service ${SERVICE_NAME} from systemd..."
rm -f "/etc/systemd/system/${SERVICE_NAME}.service" || { echo "Failed to remove $SERVICE_NAME"; exit 1; }
log "Reloading systemd daemon..."
systemctl daemon-reload || { echo "Failed to reload systemd"; exit 1; }
log "Service ${SERVICE_NAME} has been stopped and disabled."

