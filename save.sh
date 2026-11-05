#!/bin/bash
# Pull live file(s) back into the dotfiles repo (machine → repo).
# Run this after editing deployed files directly (e.g. in ~/.config/).
#
# Usage:   ./save.sh                    # re-add all changed managed files
#          ./save.sh <destination-path> # re-add a specific file
# Example: ./save.sh ~/.config/tmux/tmux.conf

set -euo pipefail

SCRIPT_DIR=$(dirname "$(realpath "$0")")

if ! git -C "$SCRIPT_DIR" diff --cached --quiet; then
  echo "Staged changes already exist; commit or unstage them before saving." >&2
  exit 1
fi
if ! git -C "$SCRIPT_DIR" rev-parse --verify '@{upstream}' >/dev/null 2>&1 ||
  [ "$(git -C "$SCRIPT_DIR" rev-list --count '@{upstream}..HEAD')" -ne 0 ]; then
  echo "No upstream branch or unpushed commits; resolve this before saving." >&2
  exit 1
fi

chezmoi re-add --source "$SCRIPT_DIR" "$@"

# Stage only chezmoi-managed files, not other repository changes.
chezmoi --source "$SCRIPT_DIR" managed \
  --include=files,symlinks --path-style=source-relative --nul-path-separator |
  git -C "$SCRIPT_DIR" add -A --pathspec-from-file=- --pathspec-file-nul

if git -C "$SCRIPT_DIR" diff --cached --quiet; then
  echo "No managed changes to commit."
  exit 0
fi

git -C "$SCRIPT_DIR" commit -m "chore(dotfiles): sync managed files"
git -C "$SCRIPT_DIR" -c push.default=simple push
