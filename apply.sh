#!/bin/bash
# Deploy dotfiles from the repo to the machine (repo → machine).
# Run this after pulling changes or editing files in ~/dotfiles directly.
# Does: git pull → brew bundle → chezmoi apply
#
# Usage: ./apply.sh [-n|--no-brew]

SCRIPT_DIR=$(dirname "$(realpath "$0")")
SKIP_BREW=false

for arg in "$@"; do
  case $arg in
  -n | --no-brew) SKIP_BREW=true ;;
  -h | --help)
    echo "Usage: ./apply.sh [-n|--no-brew]"
    echo ""
    echo "Options:"
    echo "  -n, --no-brew   Skip 'brew bundle' (faster when you only changed dotfiles)"
    echo "  -h, --help  Show this help"
    exit 0
    ;;
  esac
done

echo "Pulling latest changes..."
git -C "$SCRIPT_DIR" pull

if [ "$SKIP_BREW" = false ]; then
  echo "Updating packages..."
  brew bundle --file="$SCRIPT_DIR/Brewfile"
fi

echo "Applying dotfiles with chezmoi..."
chezmoi apply --source "$SCRIPT_DIR"

echo "Done."
