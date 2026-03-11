#!/bin/bash
# Pull a live file back into the dotfiles repo (machine → repo).
# Run this after editing a deployed file directly (e.g. in ~/.config/).
#
# Usage:   ./save.sh <destination-path>
# Example: ./save.sh ~/.config/tmux/tmux.conf
#          ./save.sh ~/.zshrc

if [ -z "$1" ]; then
    echo "Usage: save.sh <destination-path>"
    echo "Example: save.sh ~/.zshrc"
    exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")

chezmoi re-add --source "$SCRIPT_DIR" "$1"