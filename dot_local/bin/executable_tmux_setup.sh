#!/usr/bin/env bash

for i in {1..3}; do
    case $i in
        1) NAME="Work";;
        2) NAME="Personal";;
        3) NAME="Window";;
    esac

    if ! tmux list-windows -F '#W' | grep -Fxq "$NAME"; then
        tmux new-window -n "$NAME"
    fi

    CUR_IDX=$(tmux list-windows -F '#I #W' | awk "/ $NAME$/ {print \$1}")
    tmux swap-window -s "$CUR_IDX" -t "$i"
done

tmux select-window -t "Work"

