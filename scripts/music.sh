#!/bin/bash

# ---------------- CONFIG ----------------
THEME="/usr/share/rofi/themes/gruvbox-dark-hard.rasi"
MUSIC_DIR="$HOME/Music"
SOCKET="/tmp/mpv-local.sock"
PLAYLIST_DIR="$HOME/Music/playlists"

mkdir -p "$PLAYLIST_DIR"
cd "$MUSIC_DIR" || exit 1

# ---------------- HELPERS ----------------
select_tracks() {
    find . -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.m4a" \) |
        sed 's|^\./||' |
        rofi -dmenu -matching fuzzy -i -theme "$THEME" -multi-select -p "🎧 Select Songs"
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
    name=$(rofi -dmenu -theme "$THEME" -p "💾 Save Playlist As:")
    [ -z "$name" ] && return
    echo "$pl" | jq -r '.data[].filename' >"$PLAYLIST_DIR/$name.m3u"
    notify-send "Playlist saved as $name"
}

load_playlist() {
    selected=$(find "$PLAYLIST_DIR" -type f -name "*.m3u" |
        xargs -I{} basename "{}" .m3u |
        rofi -dmenu -theme "$THEME" -p "📂 Load Playlist:")
    [ -z "$selected" ] && return
    mapfile -t playlist <"$PLAYLIST_DIR/$selected.m3u"
    rm -f "$SOCKET"
    mpv --no-video --input-ipc-server="$SOCKET" --quiet "${playlist[@]}" &
    wait_for_socket
}

append_to_playlist() {
    selected_playlist=$(find "$PLAYLIST_DIR" -type f -name "*.m3u" |
        xargs -I{} basename "{}" .m3u |
        rofi -dmenu -theme "$THEME" -p "📋 Choose Playlist to Append:")
    [ -z "$selected_playlist" ] && return
    selected_tracks=$(select_tracks)
    [ -z "$selected_tracks" ] && return
    echo "$selected_tracks" >>"$PLAYLIST_DIR/$selected_playlist.m3u"
    notify-send "Tracks appended to $selected_playlist"
}

playlist_menu() {
    choice=$(printf "💾 Save Playlist\n📂 Load Playlist\n📋 Append to Playlist" |
        rofi -dmenu -theme "$THEME" -p "🎼 Playlist Menu:")
    case "$choice" in
    "💾 Save Playlist") save_playlist ;;
    "📂 Load Playlist") load_playlist ;;
    "📋 Append to Playlist") append_to_playlist ;;
    esac
}

# ---------------- QUEUE ----------------
view_queue() {
    mpv_running || return
    echo '{ "command": ["get_property", "playlist"] }' | socat - "$SOCKET" |
        jq -r --arg dir "$MUSIC_DIR/" '
            .data[] |
            (if .current == true then "▶ " else "   " end) + (.filename | sub($dir; ""))' |
        rofi -dmenu -matching fuzzy -i -theme "$THEME" -p "🎶 Queue (> = current):" || true
}

enqueue() {
    mpv_running || return
    selected=$(select_tracks)
    [ -z "$selected" ] && return
    read_selection_into_array "$selected"
    for track in "${playlist[@]}"; do
        echo '{ "command": ["loadfile", "'"$MUSIC_DIR/$track"'", "append-play"] }' | socat - "$SOCKET"
    done
}

edit_queue() {
    mpv_running || return
    while true; do
        queue=$(echo '{ "command": ["get_property", "playlist"] }' | socat - "$SOCKET" |
            jq -r --arg dir "$MUSIC_DIR/" '
                .data[] |
                (if .current == true then "▶ " else "   " end) + (.filename | sub($dir; ""))')
        [ -z "$queue" ] && {
            notify-send "Queue is empty"
            return
        }

        mapfile -t queue_array <<<"$queue"
        menu=$(printf "%s\n" "${queue_array[@]}" | rofi -dmenu -theme "$THEME" -p "🎶 Edit Queue (J/K/DD, ESC to exit):")
        [ -z "$menu" ] && break

        index=-1
        for i in "${!queue_array[@]}"; do
            [[ "${queue_array[$i]}" == "$menu" ]] && index=$i
        done
        [ $index -eq -1 ] && continue

        action=$(rofi -dmenu -theme "$THEME" -p "Action: J=Down K=Up DD=Delete ESC=Exit")
        case "$action" in
        "J")
            if [ "$index" -lt $((${#queue_array[@]} - 1)) ]; then
                echo '{ "command": ["playlist-move", '"$index"', '"$((index + 1))"'] }' | socat - "$SOCKET"
                notify-send "Moved down: ${queue_array[$index]}"
            fi
            ;;
        "K")
            if [ "$index" -gt 0 ]; then
                echo '{ "command": ["playlist-move", '"$index"', '"$((index - 1))"'] }' | socat - "$SOCKET"
                notify-send "Moved up: ${queue_array[$index]}"
            fi
            ;;
        "dd")
            echo '{ "command": ["playlist-remove", '"$index"'] }' | socat - "$SOCKET"
            notify-send "Removed: ${queue_array[$index]}"
            ;;
        "") break ;; # ESC pressed
        esac
    done
}

queue_menu() {
    while true; do
        choice=$(printf "📜 View Queue\n➕ Enqueue\n✏️ Edit Queue\n⬅️ Back" |
            rofi -dmenu -theme "$THEME" -p "📜 Queue Menu:")
        case "$choice" in
        "📜 View Queue") view_queue ;;
        "➕ Enqueue") enqueue ;;
        "✏️ Edit Queue") edit_queue ;;
        "⬅️ Back" | "") break ;;
        esac
    done
}

# ---------------- CONTROLS ----------------
controls_menu() {
    mpv_running || return
    while true; do
        action=$(printf "⏸️ Pause/Resume\n⏭️ Next\n⏮️ Prev\n⏪ Back 10s\n⏩ Forward 10s\n🔁 Toggle Loop\n⏹️ Quit\n⬅️ Back" |
            rofi -dmenu -matching fuzzy -i -theme "$THEME" -p "🎛️ Controls:")
        case "$action" in
        "⏸️ Pause/Resume") echo '{ "command": ["cycle", "pause"] }' | socat - "$SOCKET" ;;
        "⏭️ Next") echo '{ "command": ["playlist-next"] }' | socat - "$SOCKET" ;;
        "⏮️ Prev") echo '{ "command": ["playlist-prev"] }' | socat - "$SOCKET" ;;
        "⏪ Back 10s") echo '{ "command": ["seek", -10, "relative"] }' | socat - "$SOCKET" ;;
        "⏩ Forward 10s") echo '{ "command": ["seek", 10, "relative"] }' | socat - "$SOCKET" ;;
        "🔁 Toggle Loop") echo '{ "command": ["cycle", "loop-playlist"] }' | socat - "$SOCKET" ;;
        "⏹️ Quit")
            echo '{ "command": ["quit"] }' | socat - "$SOCKET"
            break
            ;;
        "⬅️ Back" | "") break ;;
        esac
    done
}

# ---------------- MAIN LOOP ----------------
while true; do
    main_menu=$(printf "🎵 Play\n📜 Queue\n📂 Playlist\n🎛️ Controls\n❌ Exit" |
        rofi -dmenu -matching fuzzy -i -theme "$THEME" -p "🎶 Select Mode:")
    [ -z "$main_menu" ] && break

    case "$main_menu" in
    "🎵 Play")
        rm -f "$SOCKET"
        selected=$(select_tracks)
        [ -z "$selected" ] && continue
        read_selection_into_array "$selected"
        mpv --no-video --input-ipc-server="$SOCKET" --quiet "${playlist[@]}" &
        wait_for_socket
        ;;
    "📜 Queue") queue_menu ;;
    "📂 Playlist") playlist_menu ;;
    "🎛️ Controls") controls_menu ;;
    "❌ Exit") break ;;
    esac
done
