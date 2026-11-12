#!/bin/bash
# Deploy dotfiles from the repo to the machine (repo → machine).
# Deploy the current checkout without pulling or pushing Git changes.
# Does: chezmoi apply → OpenCode plugin update

set -euo pipefail

SCRIPT_DIR=$(dirname "$(realpath "$0")")

if [ "$#" -eq 1 ] && { [ "$1" = -h ] || [ "$1" = --help ]; }; then
  echo "Usage: ./apply.sh"
  exit 0
fi

if [ "$#" -eq 1 ] && [ "$1" = --no-brew ]; then
  # Older installed dotfiles-sync wrappers still pass this flag.
  shift
fi

if [ "$#" -ne 0 ]; then
  echo "Usage: ./apply.sh" >&2
  exit 2
fi

echo "Applying dotfiles with chezmoi..."
chezmoi apply --source "$SCRIPT_DIR"
opencode plugin update || exit 1

echo "Done."
