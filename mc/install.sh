#!/bin/bash

# Check if mc is installed
if ! command -v mc >/dev/null 2>&1; then
    echo "Midnight Commander (mc) is not installed. Installing now..."
    sudo apt install -y mc
    echo "mc installed successfully."
else
    echo "mc is already installed. Skipping installation."
fi

# Ensure configuration directories exist
mkdir -p ~/.config/mc/
mkdir -p ~/.local/share/mc/skins

# Download mc configuration files
curl -s -o ~/.config/mc/ini \
    https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/ini
curl -s -o ~/.config/mc/filehighlight.ini \
    https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/filehighlight.ini
curl -s -o ~/.config/mc/panels.ini \
    https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/panels.ini
curl -s -o ~/.local/share/mc/skins/onedark.ini \
    https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/skins/onedark.ini

echo "mc configuration and theme have been applied."
