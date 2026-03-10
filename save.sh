#!/bin/bash
# Save changes from a destination file back to the dotfiles source.
# Usage: ./save.sh <destination-path>
# Example: ./save.sh ~/.zshrc

if [ -z "$1" ]; then
    echo "Usage: save.sh <destination-path>"
    echo "Example: save.sh ~/.zshrc"
    exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")

chezmoi re-add --source "$SCRIPT_DIR" "$1"