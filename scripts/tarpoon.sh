#!/usr/bin/env bash

CACHE="$HOME/.cache/tarpoon_cache"

touch "$CACHE"

value="$1"

Def_harpoon() {
    grep -vxF "edit" "$CACHE" >"${CACHE}.tmp"
    mv "${CACHE}.tmp" "$CACHE"
    echo "edit" >>"$CACHE"
}

List_harpoon() {
    cat "$CACHE" | nl
}

Add_harpoon() {
    dir="$PWD"
    basedir="$(basename "$dir")"

    if ! grep -qxF "$dir" "$CACHE"; then
        echo "$dir" >>"$CACHE"
        notify-send "Added to Harpoon" "$basedir"
    else
        notify-send "Already exists" "$basedir"
    fi

}

Home_harpoon() {
    local session_name="home"

    if tmux has-session -t "$session_name" 2>/dev/null; then
        [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
    else
        tmux new-session -d -s "$session_name" -c "$HOME" -n "main"
        [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
    fi
    exit 0

}

Make_harpoon() {
    local path="$1"
    session_name=$(basename "$path" | tr . _)

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        tmux new-session -ds "$session_name" -c "$path"
    fi
    tmux switch-client -t "$session_name"
}

Check_harpoon() {
    local path="$1"

    if [[ "$HOME" = "$path" ]]; then
        Home_harpoon
    else
        Make_harpoon "$path"
    fi
}

Jump_harpoon() {

    local path=$(
        List_harpoon | fzf \
            --bind "q:abort" \
            --reverse \
            --inline-info \
            --tmux center | awk '{print $2}'
    )

    if [ -d "$path" ]; then
        if [ -n "$TMUX" ]; then
            Check_harpoon "$path"
        fi
    elif [[ "$path" = "edit" ]]; then
        tmux new-window -n "edit" nvim "$CACHE"
    fi
}

Def_harpoon

case "$value" in
-H)
    Add_harpoon
    ;;
-h)
    Jump_harpoon
    ;;
*)
    # TODO:
    ;;
esac

# Add_harpoon
# Jump_harpoon "$(List_harpoon | fzf)"
