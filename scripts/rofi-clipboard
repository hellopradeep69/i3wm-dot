#!/bin/bash

# Number of clipboard items to show
LIMIT=20

# Get last $LIMIT clipboard entries using CopyQ list & read
menu=""
for i in $(seq 0 $((LIMIT - 1))); do
    entry=$(copyq read $i 2>/dev/null | tr '\n' ' ' | cut -c1-80)
    [ -n "$entry" ] && menu+="$i: $entry\n"
done

# Show in Rofi
choice=$(echo -e "$menu" | rofi -dmenu -p "Clipboard")

# Extract index
index=$(echo "$choice" | cut -d: -f1)

# Paste the selected entry
if [[ "$index" =~ ^[0-9]+$ ]]; then
    copyq select "$index"
    copyq paste
fi
