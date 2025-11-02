#!/bin/bash

THEME="dmenu"
SOCKET="/tmp/mpv-local.sock"

# Check if MPV is running
[ ! -S "$SOCKET" ] && notify-send "MPV not running" && exit

# Show control menu
action=$(printf "⏪ Back 10s\n⏩ Forward 10s\n⏸️ Pause/Resume\n⏭️ Next\n⏮️ Prev\n🔁 Toggle Loop\n⏹️ Quit" | rofi -dmenu -theme "$THEME" -p "🎵 Controls")

# Send corresponding MPV JSON IPC commands
case "$action" in
    "⏪ Back 10s")
        echo '{ "command": ["seek", -10, "relative"] }' | socat - "$SOCKET"
        ;;
    "⏩ Forward 10s")
        echo '{ "command": ["seek", 10, "relative"] }' | socat - "$SOCKET"
        ;;
    "⏸️ Pause/Resume")
        echo '{ "command": ["cycle", "pause"] }' | socat - "$SOCKET"
        ;;
    "⏭️ Next")
        echo '{ "command": ["playlist-next"] }' | socat - "$SOCKET"
        ;;
    "⏮️ Prev")
        echo '{ "command": ["playlist-prev"] }' | socat - "$SOCKET"
        ;;
    "🔁 Toggle Loop")
        echo '{ "command": ["cycle", "loop-playlist"] }' | socat - "$SOCKET"
        ;;
    "⏹️ Quit")
        echo '{ "command": ["quit"] }' | socat - "$SOCKET"
        ;;
esac
