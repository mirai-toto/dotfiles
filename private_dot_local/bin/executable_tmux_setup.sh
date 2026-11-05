#!/usr/bin/env bash
# Ensure a standard set of named windows exist and are in the correct order.
# Runs automatically on new sessions via the after-new-session hook.
# Configure windows in options.conf: set -g @setup_windows "Work Personal Window"

IFS=' ' read -ra WINDOWS <<< "$(tmux show-option -gv @setup_windows)"

# Rename the initial window instead of creating a new one (avoids a 4th stray window)
tmux rename-window -t 1 "${WINDOWS[0]}"

# Create any remaining missing windows
for name in "${WINDOWS[@]:1}"; do
    if ! tmux list-windows -F '#W' | grep -Fxq "$name"; then
        tmux new-window -n "$name"
    fi
done

# Move windows into their correct positions (1-indexed)
for i in "${!WINDOWS[@]}"; do
    name="${WINDOWS[$i]}"
    target=$((i + 1))
    current=$(tmux list-windows -F '#I #W' | awk -v n="$name" '$2 == n {print $1}')
    [[ "$current" != "$target" ]] && tmux swap-window -s "$current" -t "$target"
done

tmux select-window -t "${WINDOWS[0]}"