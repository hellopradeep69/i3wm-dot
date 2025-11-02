#!/usr/bin/env bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

FILE="$1"

check_argument() {
    if [ ! -f "$FILE" ]; then
        echo -e "${RED}Error:${RESET} File not found!"
        exit 1
    fi
}

check_tmux() { if [ -z "$TMUX" ]; then
    echo "Not Inside tmux session"
else
    session_name="$(tmux display-message -p '#S')"
    # echo "$session_name"
fi; }

window_create() {

    win_name="Debug"
    # win_name=$(basename "$FILE" | tr . _)
    # Check if window already exists
    if ! tmux list-windows -t "$session_name" | grep -q "$win_name"; then
        tmux new-window -t "$session_name" -n "$win_name"
    else
        tmux select-window -t "$session_name:$win_name"
    fi
}

debug_start() {
    check_argument
    check_tmux
    window_create
    tmux send-keys -t "$session_name:$win_name" "clear;code "$FILE"" Enter
    tmux select-window -t "$session_name:$win_name"
}

debug_start
