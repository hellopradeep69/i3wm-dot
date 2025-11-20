#!/usr/bin/env bash

Tmux_win() {
    Session_name=$(tmux display-message -p '#S')
    Win_name="Code"
    # echo "$Session_name" && echo "$Win_name"

    tmux kill-window -t "$Session_name:$Win_name"

    if ! tmux list-windows -t "$Session_name" | grep -q "$Win_name"; then
        tmux new-window -t "$Session_name" -n "$Win_name" -c "#{pane_current_path}"
    else
        tmux select-window -t "$Session_name:$Win_name"
    fi

    tmux send-keys -t "$Session_name:$Win_name" "clear" C-m
}

Tmux_win
