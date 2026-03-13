#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
IMAGE_NAME="dotfiles-test"

echo "Building Docker image..."
docker build -t "$IMAGE_NAME" -f "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR"

echo "Running install in container (interactive shell after install)..."
docker run --rm -it "$IMAGE_NAME"
