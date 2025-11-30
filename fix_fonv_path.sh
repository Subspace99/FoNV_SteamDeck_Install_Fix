#!/usr/bin/env bash

# Proton prefix registry file
SYSTEM_REG="$HOME/.local/share/Steam/steamapps/compatdata/22380/pfx/system.reg"

# Check that system.reg exists
if [[ ! -f "$SYSTEM_REG" ]]; then
    echo "Error: system.reg not found at: $SYSTEM_REG Please run the game through Steam first"
    exit 1
fi

# Get the current directory (game install folder)
LINUX_PATH="$(pwd)"

# Convert to Proton path:
# 1. Prefix with Z:
# 2. Replace "/" with "\\"
# 3. Add trailing "\\"
PROTON_PATH="Z:${LINUX_PATH//\//\\\\}\\\\"

# Registry header
HEADER='[Software\\Wow6432Node\\Bethesda Softworks\\FalloutNV]'

# Remove any existing block for FalloutNV
sed -i '/\[Software\\\\Wow6432Node\\\\Bethesda Softworks\\\\FalloutNV\]/,/^$/d' "$SYSTEM_REG"

# Append a fresh, clean block
{
    echo "$HEADER"
    echo "\"Installed Path\"=\"$PROTON_PATH\""
    echo
} >> "$SYSTEM_REG"

echo "Installed Path set to: $PROTON_PATH"
