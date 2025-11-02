#!/usr/bin/env bash
# tmux-fzf-dashboard.sh
# Unified tmux dashboard: sessions + directories + Home

# -------------------------------
# FUNCTIONS
# -------------------------------

list_sessions() {
    tmux list-sessions -F "#{session_name} (#{windows} windows, created: #{session_created})" 2>/dev/null || true
}

format_session() {
    local line="$1"
    local name marker smarker

    current_session=""
    [ -n "$TMUX" ] && current_session=$(tmux display-message -p '#S')

    name=$(echo "$line" | awk '{print $1}')

    # Count total panes across all windows
    total_panes=$(tmux list-windows -t "$name" -F "#{window_panes}" 2>/dev/null | awk '{s+=$1} END{print s}')

    # attached marked in existing session if you are attach to it
    marker=""
    [ "$name" == "$current_session" ] && marker=""

    # Check if session has multiple panes in any window
    if tmux list-windows -t "$name" -F "#{window_panes}" | grep -q '[2-9]'; then
        smarker="[Z]"
    else
        smarker=""
    fi

    printf "%-15s [%d pane(s)] %s %s\n" "$name" "$total_panes" "$marker" "$smarker"
}

session_exists() {
    tmux has-session -t "$1" 2>/dev/null
}

# -------------------------------
# Exclude Directories Mention
# -------------------------------
EXCLUDE_DIRS=(~/.tmux ~/Templates ~/.cache ~/.rustup ~/.npm ~/.zen ~/.linuxmint
    ~/Public ~/.icons ~/Desktop ~/.cargo ~/.mozilla ~/.themes ~/.w3m ~/.golf
    ~/.java ~/.cursor ~/fastfetch ~/Telegram)

# Build find exclude arguments
exclude_args=""
for d in "${EXCLUDE_DIRS[@]}"; do
    exclude_args+=" -not -path '$d*'"
done

# -------------------------------
# BUILD MENU
# -------------------------------

# Existing sessions
sessions=""
# existing=$(list_sessions | sort)
existing=$(list_sessions | sort -t: -k2,2n)
if [ -n "$existing" ]; then
    while read -r line; do
        sessions+=$(format_session "$line")$'\n'
    done <<<"$existing"
fi

# Directories
dirs=$(eval "find ~ -mindepth 1 -maxdepth 2 -type d -not -path '*/\.git*' $exclude_args 2>/dev/null")

menu="$sessions$dirs
[Delete]"

# -------------------------------
# SELECT ITEM
# -------------------------------
selected=$(
    echo -e "$menu" | fzf \
        --prompt="Select tmux item (q to quit): " \
        --border \
        --reverse \
        --bind "j:down,k:up,q:abort" \
        --cycle
)

[ -z "$selected" ] && exit 0

# -------------------------------
# HANDLE SELECTION
# -------------------------------

if [[ "$selected" == "[Delete]" ]]; then
    while true; do
        # List sessions with extra info for clarity

        del_session=$(
            tmux list-sessions -F "#{session_name} (#{windows} windows, created: #{session_created})" 2>/dev/null |
                sort -t: -k2,2n |
                while read -r line; do
                    format_session "$line"
                done | fzf --prompt="Select session to delete (q to quit): " \
                --border \
                --cycle --reverse \
                --bind "j:down,k:up,q:abort"
        )

        # Exit if user pressed q or nothing selected
        [ -z "$del_session" ] && break

        # Extract only the session name (first word before space)
        del_session_name=$(echo "$del_session" | awk '{print $1}')

        # Confirm deletion
        read -rp "Are you sure you want to delete session '$del_session_name'? [y/N]: " confirm
        confirm=${confirm,,} # convert to lowercase
        if [[ "$confirm" == "y" ]]; then
            tmux kill-session -t "$del_session_name"
            echo "Session '$del_session_name' deleted."
        else
            echo "Aborted deletion."
        fi
    done
    exit 0

elif [[ -d "$selected" ]]; then
    dir="$selected"
    # Unique session name: relative path to HOME
    rel_path=$(realpath --relative-to="$HOME" "$dir")
    session_name=$(echo "$rel_path" | tr / _ | tr -cd '[:alnum:]_')

    if session_exists "$session_name"; then
        [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
    else
        tmux new-session -d -s "$session_name" -c "$dir" -n "main"
        [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
    fi
    exit 0

else
    # Existing session
    session_name=$(echo "$selected" | awk '{print $1}')
    [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
fi
