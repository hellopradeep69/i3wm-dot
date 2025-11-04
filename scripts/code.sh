#!/usr/bin/env bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

if [ $# -ne 1 ]; then
    echo -e "${YELLOW}Usage:${RESET} $0 <filename>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo -e "${RED}Error:${RESET} File not found!"
    exit 1
fi

EXT="${FILE##*.}"
BASENAME="${FILE%.*}"
CLASSNAME=$(basename "$BASENAME")

echo " "
echo -e "${GREEN}=== OUTPUT ${FILE} ===${RESET}"

case "$EXT" in
py)
    python3 "$FILE"
    ;;
java)
    javac "$FILE" && java "$CLASSNAME"
    ;;
c)
    gcc "$FILE" -o "$BASENAME" && "$BASENAME"
    ;;
cpp)
    g++ "$FILE" -o "$BASENAME" && "$BASENAME"
    ;;
sh)
    bash "$FILE"
    ;;
lua)
    lua "$FILE"
    ;;
js)
    node "$FILE"
    ;;
*)
    echo -e "${RED}Error:${RESET} Unsupported file type: $EXT"
    exit 1
    ;;
esac

EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo -e "${RED}=== PROGRAM ERROR (exit code $EXIT_CODE) ===${RESET}"
fi
