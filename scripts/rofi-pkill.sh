#!/bin/bash

# Get only real GUI apps with their window titles and PIDs
apps=$(wmctrl -lp | while read -r winid desktop pid host title; do
    cmd=$(ps -p "$pid" -o comm=)
    echo "$pid $cmd - $title"
done | sort -u)

# Show in Rofi
choice=$(echo "$apps" | rofi -dmenu -p "Kill App (PID CMD - Title)")

# Kill selected app
if [[ -n "$choice" ]]; then
    pid=$(echo "$choice" | awk '{print $1}')
    kill "$pid" && notify-send "Rofi Kill" "Killed: $choice"
fi
