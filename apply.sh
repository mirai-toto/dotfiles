#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

echo "Pulling latest changes..."
git -C "$SCRIPT_DIR" pull

echo "Updating packages..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

echo "Applying dotfiles with chezmoi..."
chezmoi apply --source "$SCRIPT_DIR"

echo "Done."
