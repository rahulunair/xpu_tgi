#!/bin/bash

SERVICE_NAME=$(basename "$(pwd)")

echo "Checking status of service ${SERVICE_NAME}..."
systemctl status "$SERVICE_NAME"

