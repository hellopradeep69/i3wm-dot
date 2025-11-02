#!/bin/sh
# for writring notes and stuff i have in  mind
TERMINAL="${TERMINAL:-wezterm}" # Or foot, alacritty, etc.
EDITOR="nvim"                   # You can change this to nano, micro, etc.
NOTE_DIR="$HOME/Notes/"
DESKTOP="4"

mkdir -p "$NOTE_DIR"

launch_note() {
    local file="$1"

    # Switch to desktop 7
    bspc desktop "$DESKTOP" -f

    # Open note in terminal (which will appear in desktop 7)
    setsid -f "$TERMINAL" -e "$EDITOR" "$file" >/dev/null 2>&1
}

new_note() {
    name=$(rofi -dmenu -p "Enter note name")
    [ -z "$name" ] && exit 0
    name=$(echo "$name" | tr ' ' '-')
    launch_note "$NOTE_DIR$name.md"
}

select_note() {
    files=$(ls -1t "$NOTE_DIR" 2>/dev/null)
    choice=$(printf "New\n%s" "$files" | rofi -dmenu -p "Choose note or create new")
    case "$choice" in
    New) new_note ;;
    *.md) launch_note "$NOTE_DIR$choice" ;;
    *) exit ;;
    esac
}

select_note
