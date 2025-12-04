#!/usr/bin/env bash

# Get the Steam library paths from libraryfolders.vdf
get_steam_library_paths() {
    local library_folders_file="$HOME/.local/share/Steam/config/libraryfolders.vdf"

    if [ -f "$library_folders_file" ]; then
        grep "\"path\"" "$library_folders_file" | awk -F'"' '{print $4}'
    else
        echo "$HOME/.local/share/Steam"  # Default if file not found
    fi
}

# Game App ID (Fallout New Vegas)
APP_ID="22380"
SYSTEM_REG="$HOME/.local/share/Steam/steamapps/compatdata/$APP_ID/pfx/system.reg"

# Find the installation folder for the game
get_game_install_folder() {
    for LIB in $(get_steam_library_paths); do
        local manifest="$LIB/steamapps/appmanifest_$APP_ID.acf"
        if [ -f "$manifest" ]; then
            local installdir
            installdir=$(grep -m 1 '"installdir"' "$manifest" | awk -F'"' '{print $4}')
            echo "$LIB/steamapps/common/$installdir"
            return
        fi
    done
    echo ""
}

# Check that system.reg exists
if [[ ! -f "$SYSTEM_REG" ]]; then
    echo "Error: system.reg not found at: $SYSTEM_REG. Please run the game through Steam first."
    exit 1
fi

# Get install folder
INSTALL_FOLDER="$(get_game_install_folder)"
if [[ -z "$INSTALL_FOLDER" ]]; then
    echo "Error: Installation folder for Fallout New Vegas not found."
    exit 1
fi

# Convert install folder path for Proton
PROTON_PATH="Z:${INSTALL_FOLDER//\//\\\\}\\\\"

# Registry header
HEADER='[Software\\Wow6432Node\\Bethesda Softworks\\FalloutNV]'

# Remove any existing FalloutNV block
sed -i '/\[Software\\\\Wow6432Node\\\\Bethesda Softworks\\\\FalloutNV\]/,/^$/d' "$SYSTEM_REG"

# Append new block
{
    echo "$HEADER"
    echo "\"Installed Path\"=\"$PROTON_PATH\""
    echo
} >> "$SYSTEM_REG"

echo "Installed Path set to: $PROTON_PATH"
