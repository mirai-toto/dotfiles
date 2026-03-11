#!/bin/bash
# Deploy dotfiles from the repo to the machine (repo → machine).
# Run this after pulling changes or editing files in ~/dotfiles directly.
# Does: git pull → brew bundle → chezmoi apply
#
# Usage: ./apply.sh

SCRIPT_DIR=$(dirname "$(realpath "$0")")

echo "Pulling latest changes..."
git -C "$SCRIPT_DIR" pull

echo "Updating packages..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

echo "Applying dotfiles with chezmoi..."
chezmoi apply --source "$SCRIPT_DIR"

echo "Done."
