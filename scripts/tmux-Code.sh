#!/usr/bin/env bash

# Variable
Session_name=$(tmux display-message -p '#S')
Win_name="Code"

Tmux_win() {
    tmux kill-window -t "$Session_name:$Win_name"

    if ! tmux list-windows | grep -q "$Win_name"; then
        tmux new-window -t "$Session_name" -n "$Win_name" -c "#pane_current_path"
    else
        tmux select-window -t "$Session_name:$Win_name"

    fi
}

Tmux_win
