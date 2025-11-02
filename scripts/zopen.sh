#!/usr/bin/env bash

Pdf_dir="$HOME/Downloads"
DESKTOP="3"

cd "$Pdf_dir" || exit 1

pdf=$(find -type f -iname '*.pdf' | fzf)

[ -z "$pdf" ] && exit 0

# Open Zathura detached from tmux
setsid zathura "$pdf" >/dev/null 2>&1 &

# Give it a short moment to appear
sleep 0.1

# Switch workspace and move Zathura window
bspc desktop "$DESKTOP" -f
bspc node -d "$DESKTOP"
