#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

echo "Pulling latest changes..."
git -C "$SCRIPT_DIR" pull

echo "Updating packages..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

echo "Re-stowing dotfiles..."
cd "$SCRIPT_DIR" || exit
stow --restow -t "$HOME" tmux
stow --restow -t "$HOME" shell
stow --restow -t "$HOME" git
stow --restow -t "$HOME/.local/bin" scripts
stow --restow -t "$HOME/.config" nvim

echo "Done."
