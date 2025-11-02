#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/themes/spot.rasi"
ROFI_OPTS="-theme $ROFI_THEME -matching fuzzy -i"

declare -A groups=(
    ["one"]=1 ["two"]=2 ["three"]=3 ["four"]=4 ["five"]=5
    ["six"]=6 ["seven"]=7 ["eight"]=8 ["nine"]=9 ["zero"]=0
)

Input=$(rofi -dmenu $ROFI_OPTS)
[ -z "$Input" ] && exit 0

read -r Prefix Query <<<"$Input"
# echo "Prefix: $Prefix"
# echo "Query: $Query"

if [[ "$Prefix" = "move" || "$Prefix" = "mv" ]]; then
    if [[ -n "${groups[$Query]}" ]]; then
        qtile cmd-obj -o window -f togroup -a "${groups[$Query]}"
        exit 0
    else
        notify-send "Unknown workspace '$Query'"
        exit 1
    fi
fi

case "$Prefix" in
c) url="https://chat.openai.com/?q=$query" ;;
r) url="https://reddit.com/r/$query" ;;
d) url="https://duckduckgo.com/?q=$query" ;;
b) url="https://search.brave.com/search?q=$query" ;;
w) url="https://en.wikipedia.org/wiki/$query" ;;
y) url="https://www.youtube.com/results?search_query=$query" ;;
g) url="https://github.com/search?q=$query" ;;
x) qtile cmd-obj -o window -f kill ;;              # close focused window
f) qtile cmd-obj -o window -f toggle_fullscreen ;; # toggle fullscreen
wifi) ~/.local/bin/rofi-wifi.sh ;;
m) ~/.local/bin/rofipl2.sh ;;
sc) gnome-screenshot ;;
*) notify-send "Unknown prefix '$prefix'" && exit 1 ;;
esac

# -----------------------------
# Open URL if defined
# -----------------------------
[ -n "$url" ] && xdg-open "$url"
