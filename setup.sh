#!/bin/bash

# Get the current user's UID and GID
UID=$(id -u) || { echo "Failed to retrieve UID"; exit 1; }
GID=$(id -g) || { echo "Failed to retrieve GID"; exit 1; }

# Export variables for Docker Compose
export UID="${UID}"
export GID="${GID}"

# Switch to this script's directory (project directory)
cd "$(dirname "$0")" || exit

# Print UID and GID for verification
echo "Using UID=${UID} and GID=${GID}"

# Build and start the containers
docker compose build --no-cache --build-arg UID="${UID}" --build-arg GID="${GID}"
docker compose up -d
