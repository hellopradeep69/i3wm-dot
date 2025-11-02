#!/bin/bash

# ==============================
# Config
# ==============================
ROFI_THEME="$HOME/.config/rofi/themes/spot.rasi"
ROFI_THEME2="$HOME/.config/rofi/themes/demnu.rasi"

ROFI_OPTS="-theme $ROFI_THEME -matching fuzzy -i"
ROFI_OPTS2="-theme $ROFI_THEME2 -matching fuzzy -i"

# ==============================
# Workspace word mapping
# ==============================
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

# ==============================
# Prompt for input
# ==============================
input=$(rofi -dmenu $ROFI_OPTS -p "Search (c,r,d,y,w,g,b)")

[ -z "$input" ] && exit 1

# Extract prefix (first word) and query (rest)
prefix=$(echo "$input" | awk '{print $1}')
query=$(echo "$input" | cut -d' ' -f2- | xargs)

# ==============================
# Workspace direct switch
# ==============================
if [[ -n "${ws_map[$prefix]}" ]]; then
    bspc desktop -f "${ws_map[$prefix]}"
    exit 0
fi

# ==============================
# Handle prefixes
# ==============================
case "$prefix" in
c) url="https://chat.openai.com/?q=$query" ;;
r) url="https://reddit.com/r/$query" ;;
d) url="https://duckduckgo.com/?q=$query" ;;
b) url="https://search.brave.com/search?q=$query" ;;
# w) url="https://en.wikipedia.org/wiki/$query" ;;
w) .local/bin/workspace.sh ;;

y) url="https://www.youtube.com/results?search_query=$query" ;;
g) url="https://github.com/search?q=$query" ;;

*) notify-send "Unknown input '$prefix'" && exit 1 ;;
esac

# ==============================
# Open in browser
# ==============================
xdg-open "$url"
