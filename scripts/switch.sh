#!/bin/bash

ROFI_THEME="$HOME/.config/rofi/themes/spot.rasi"
ROFI_OPTS="-theme $ROFI_THEME -matching fuzzy -i"

# Map words to workspace numbers
declare -A ws_map=(
    ["one"]=1
    ["two"]=2
    ["three"]=3
    ["four"]=4
    ["five"]=5
    ["six"]=6
    ["seven"]=7
    ["eight"]=8
    ["nine"]=9
    ["zero"]=0
)

# Generate list for rofi
workspaces=$(printf "%s\n" "${!ws_map[@]}")

# Get current workspace
current=$(bspc query -D -d focused --names)

# Show rofi menu
# chosen=$(echo -e "$workspaces" | rofi -dmenu -p "Workspace:" -mesg "Current: $current")
chosen=$(rofi -dmenu $ROFI_OPTS -p "Workspace:")

# If nothing selected, exit
[ -z "$chosen" ] && exit 0

# Lookup the number
target=${ws_map[$chosen]}

# Switch to that workspace
bspc desktop -f "$target"
