#!/bin/bash

THEME="try"
PDF_DIR="$HOME/Downloads"

cd "$PDF_DIR" || exit 1

# List only PDFs and show in Rofi
pdf_file=$(find . -type f -iname "*.pdf" | sed 's|^\./||' |
    rofi -dmenu -matching fuzzy -i -theme "$THEME" -p "Select PDF")

# Exit if nothing selected
[ -z "$pdf_file" ] && exit 0

# Open selected PDF in Zathura
zathura "$PDF_DIR/$pdf_file" &
