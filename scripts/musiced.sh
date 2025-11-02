#!/usr/bin/env bash

# ---------------- CONFIG ----------------
MUSIC_DIR="$HOME/Music"
SOCKET="/tmp/mpv-local.sock"
PLAYLIST_DIR="$HOME/Music/playlists"

mkdir -p "$PLAYLIST_DIR"
cd "$MUSIC_DIR" || exit 1

# ---------------- HELPERS ----------------
select_tracks() {
    find . -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.m4a" \) |
        sed 's|^\./||' |
        fzf --multi --reverse --prompt "Select Songs: "
}

read_selection_into_array() {
    IFS=$'\n' read -d '' -r -a playlist <<<"$1"
}

wait_for_socket() {
    for i in {1..10}; do
        [ -S "$SOCKET" ] && return
        sleep 0.2
    done
    notify-send "MPV socket not available"
    exit 1
}

mpv_running() {
    [ ! -S "$SOCKET" ] && notify-send "MPV is not running" && return 1
    return 0
}

# ---------------- PLAYLIST ----------------
save_playlist() {
    mpv_running || return
    pl=$(echo '{ "command": ["get_property", "playlist"] }' | socat - "$SOCKET")
    read -rp "Save Playlist As: " name
    [ -z "$name" ] && return
    echo "$pl" | jq -r '.data[].filename' >"$PLAYLIST_DIR/$name.m3u"
    notify-send "Playlist saved as $name"
}

load_playlist() {
    selected=$(find "$PLAYLIST_DIR" -type f -name "*.m3u" |
        xargs -I{} basename "{}" .m3u |
        fzf --prompt "Load Playlist: ")
    [ -z "$selected" ] && return
    mapfile -t playlist <"$PLAYLIST_DIR/$selected.m3u"
    rm -f "$SOCKET"
    mpv --no-video --input-ipc-server="$SOCKET" --quiet "${playlist[@]}" &
    wait_for_socket
}

append_to_playlist() {
    selected_playlist=$(find "$PLAYLIST_DIR" -type f -name "*.m3u" |
        xargs -I{} basename "{}" .m3u |
        fzf --prompt "Choose Playlist to Append: ")
    [ -z "$selected_playlist" ] && return
    selected_tracks=$(select_tracks)
    [ -z "$selected_tracks" ] && return
    echo "$selected_tracks" >>"$PLAYLIST_DIR/$selected_playlist.m3u"
    notify-send "Tracks appended to $selected_playlist"
}

shuffle_playlist() {
    selected=$(find "$PLAYLIST_DIR" -type f -name "*.m3u" |
        xargs -I{} basename "{}" .m3u |
        fzf --prompt "Select Playlist to Shuffle: ")
    [ -z "$selected" ] && return

    input_file="$PLAYLIST_DIR/$selected.m3u"
    tmp_file=$(mktemp --suffix=.m3u)
    shuf "$input_file" >"$tmp_file"

    rm -f "$SOCKET"
    mpv --no-video --input-ipc-server="$SOCKET" --quiet --playlist="$tmp_file" &
    wait_for_socket
    rm -f "$tmp_file"
}

playlist_menu() {
    choice=$(printf "Load Playlist\nSave Playlist\nAppend to Playlist\nShuffle Playlist" |
        fzf --prompt "Playlist Menu: ")
    case "$choice" in
    "Save Playlist") save_playlist ;;
    "Load Playlist") load_playlist ;;
    "Append to Playlist") append_to_playlist ;;
    "Shuffle Playlist") shuffle_playlist ;;
    esac
}

# ---------------- QUEUE ----------------
enqueue() {
    mpv_running || return
    selected=$(select_tracks)
    [ -z "$selected" ] && return
    read_selection_into_array "$selected"
    for track in "${playlist[@]}"; do
        echo '{ "command": ["loadfile", "'"$MUSIC_DIR/$track"'", "append-play"] }' | socat - "$SOCKET"
    done
}

# ---------------- CONTROLS ----------------
controls_menu() {
    mpv_running || return
    while true; do
        action=$(printf "Pause/Resume\nNext\nPrev\nBack 10s\nForward 10s\nToggle Loop\nQuit\nBack" |
            fzf --prompt "Controls: ")
        case "$action" in
        "Pause/Resume") echo '{ "command": ["cycle", "pause"] }' | socat - "$SOCKET" ;;
        "Next") echo '{ "command": ["playlist-next"] }' | socat - "$SOCKET" ;;
        "Prev") echo '{ "command": ["playlist-prev"] }' | socat - "$SOCKET" ;;
        "Back 10s") echo '{ "command": ["seek", -10, "relative"] }' | socat - "$SOCKET" ;;
        "Forward 10s") echo '{ "command": ["seek", 10, "relative"] }' | socat - "$SOCKET" ;;
        "Toggle Loop") echo '{ "command": ["cycle", "loop-playlist"] }' | socat - "$SOCKET" ;;
        "Quit")
            echo '{ "command": ["quit"] }' | socat - "$SOCKET"
            break
            ;;
        "Back" | "") break ;;
        esac
    done
}

# ---------------- MAIN LOOP ----------------
while true; do
    main_menu=$(printf "Play\nQueue\nPlaylist\nControls\nExit" | fzf --prompt "Select Mode: ")
    [ -z "$main_menu" ] && break

    case "$main_menu" in
    "Play")
        rm -f "$SOCKET"
        selected=$(select_tracks)
        [ -z "$selected" ] && continue
        read_selection_into_array "$selected"
        mpv --no-video --input-ipc-server="$SOCKET" --quiet "${playlist[@]}" &
        wait_for_socket
        ;;
    "Queue") enqueue ;;
    "Playlist") playlist_menu ;;
    "Controls") controls_menu ;;
    "Exit") break ;;
    esac
done
