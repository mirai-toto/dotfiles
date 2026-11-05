#!/usr/bin/env bash
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/tmux_enabled"

if [[ "$1" == "on" ]]; then
  touch "$STATE_FILE" && echo "tmux auto-attach: on"
elif [[ "$1" == "off" ]]; then
  rm -f "$STATE_FILE" && echo "tmux auto-attach: off"
else
  echo "Usage: $(basename "$0") [on|off]" >&2
  exit 1
fi
