#!/bin/bash

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (with sudo)"
    exit 1
fi

SERVICE_NAME=$(basename "$(pwd)")
SERVICE_FILE="${SERVICE_NAME}.service"
SYSTEMD_PATH="/etc/systemd/system/${SERVICE_FILE}"

if [ ! -f "$SERVICE_FILE" ]; then
    echo "Service file '$SERVICE_FILE' not found in $(pwd). Exiting."
    exit 1
fi

log "Installing service ${SERVICE_NAME}..."
cp "$SERVICE_FILE" "$SYSTEMD_PATH" || { echo "Failed to copy $SERVICE_FILE"; exit 1; }
log "Reloading systemd daemon..."
systemctl daemon-reload
log "Enabling and starting service ${SERVICE_NAME}..."
systemctl enable "$SERVICE_NAME" || { echo "Failed to enable $SERVICE_NAME"; exit 1; }
systemctl start "$SERVICE_NAME" || { echo "Failed to start $SERVICE_NAME"; exit 1; }
log "Service ${SERVICE_NAME} is running. Use the following command to check its status:"
echo "systemctl status ${SERVICE_NAME}"
