#!/usr/bin/bash

# tmux list-sessions -F "[TMUX] #{session_name} #{pane_index}" 2>/dev/null | grep -vFx "[TMUX] $current_session"

exclude_dir() {
    EXCLUDE_DIRS=(~/.tmux ~/Templates ~/.cache ~/.rustup ~/.npm ~/.zen ~/.linuxmint
        ~/Public ~/.icons ~/Desktop ~/.cargo ~/.mozilla ~/.themes ~/.w3m ~/.golf ~/.java ~/.cursor)

    exclude_args=""
    for d in "${EXCLUDE_DIRS[@]}"; do
        exclude_args+=" -not -path '$d*'"
    done

    eval "find ~ -mindepth 1 -maxdepth 2 -type d -not -path '*/\.git*' $exclude_args 2>/dev/null"
}

fzfdir() {
    #{?#{==:#{pane_index},0},[ ],[ Z ]}

    # list TMUX sessions
    if [[ -n "${TMUX}" ]]; then
        current_session=$(tmux display-message -p '#S')
        tmux list-sessions -F "[TMUX] #{session_name} #{?session_attached,, } " 2>/dev/null | sort
    else
        tmux list-sessions -F "[TMUX] #{session_name}" 2>/dev/null
    fi

    exclude_dir

}

open_fzf() {

    selected=$(fzfdir | fzf \
        --prompt="Select tmux item (q to quit): " \
        --border \
        --reverse \
        --bind "q:abort" \
        --cycle)

    [ -z "$selected" ] && exit 0

    if [[ -d "$selected" ]]; then
        dir="$selected"

        rel_path=$(realpath --relative-to="$HOME" "$dir")
        session_name=$(echo "$rel_path" | tr / _ | tr -cd '[:alnum:]_')

        if tmux has-session -t "$1" "$session_name" 2>/dev/null; then
            [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
        else
            tmux new-session -d -s "$session_name" -c "$dir" -n "main"
            [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
        fi
        exit 0

    else
        # Existing session
        session_name=$(echo "$selected" | awk '{print $2}')
        [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
    fi
}

open_it() {
    rel_path=$(realpath --relative-to="$HOME" "$selected")
    selected_name=$(echo "$rel_path" | tr / _ | tr -cd '[:alnum:]_')

    # echo "$selected_name"
    if ! tmux has-session -t "$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$selected" -n "main"
        tmux select-window -t "$selected_name:1"
    fi

    tmux switch-client -t "$selected_name"
}

# panes_check

case "$name" in
fdir | -f)
    open_fzf
    ;;
*)
    open_fzf
    ;;
esac
