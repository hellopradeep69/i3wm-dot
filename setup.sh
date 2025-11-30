#!/usr/bin/env bash

# failure or sucess
set -e

CONFIG_DIR="$HOME/.config"
REPO_DIR="$(pwd)"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
LOCAL_BIN="$HOME/.local/bin"

Backup_dir() {
    echo "backing up your old stuff to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    for dir in i3 picom rofi dunst fastfetch zathura; do
        if [ -d "$CONFIG_DIR/$dir" ]; then
            mv "$CONFIG_DIR/$dir" "$BACKUP_DIR/"
            echo "Backed up $dir"
            echo "Completed backing up $dir"
        fi
    done
}

Copy_dir() {
    echo "Copying i3wm stuff"
    echo "Copying configs to $CONFIG_DIR "
    for dir in i3 i3status picom rofi dunst fastfetch zathura; do
        if [ -d "$REPO_DIR/$dir" ]; then
            cp -r "$REPO_DIR/$dir" "$CONFIG_DIR/$dir"
        fi
    done
}

Copy_desk() {
    echo "Copying .desktop files to ~/.local/share/applications"
    mkdir -p "$HOME/.local/share/applications"

    if [ -d "$REPO_DIR/desktop" ]; then
        cp -r "$REPO_DIR/desktop"/. "$HOME/.local/share/applications/"
        echo "Desktop entries copied."
    else
        echo "No 'desktop' folder found in repo."
    fi
}

Install_pack() {
    if command -v apt &>/dev/null; then
        sudo apt update
        sudo apt install -y i3 i3status rofi picom dunst fastfetch jq wezterm zsh zathura
        echo "All dependencies installed."
    elif command -v pacman &>/dev/null; then
        sudo pacman -Syu --needed i3-wm i3status rofi picom dunst fastfetch jq --noconfirm
        echo "All dependencies installed."
    else
        echo "⚠️  Unsupported package manager. Please install manually."
        echo "i3 i3status rofi picom dunst fastfetch wezterm"
    fi
}

Install_script() {
    mkdir -p "$LOCAL_BIN"

    if [ -d "$REPO_DIR/scripts" ]; then
        cp -r "$REPO_DIR/scripts/"* "$LOCAL_BIN/"
        chmod +x "$LOCAL_BIN"/*
        echo "Scripts copied and made executable."
    else
        echo "No scripts folder found in repo."
    fi
}

Install_zsh() {
    cp "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
    cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
    cp "$REPO_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
    echo " Copied .zshrc"
    echo " Copied .tmux"
    echo " Copied .wezterm"
}

Main() {

    Backup_dir
    Copy_dir
    Install_pack
    Install_script
    Install_zsh

    echo "✅ Setup complete!"
    echo "Please log out or restart select i3wm"
}

Main
