#!/bin/bash
# Pull live file(s) back into the dotfiles repo (machine → repo).
# Run this after editing deployed files directly (e.g. in ~/.config/).
#
# Usage:   ./save.sh                    # re-add all changed managed files
#          ./save.sh <destination-path> # re-add a specific file
# Example: ./save.sh ~/.config/tmux/tmux.conf

SCRIPT_DIR=$(dirname "$(realpath "$0")")

chezmoi re-add --source "$SCRIPT_DIR" "$@"

