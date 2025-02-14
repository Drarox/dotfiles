#!/bin/sh

# Check if micro is installed
if ! command -v micro >/dev/null 2>&1; then
    echo "Micro is not installed. Installing now..."

    # Global install for all users
    cd /usr/bin || exit
    curl -s https://getmic.ro/r | sudo sh
    cd ~ || exit

    # Custom clipboard for tabby
    sudo curl -s -o /usr/local/bin/micro-clip https://raw.githubusercontent.com/Drarox/dotfiles/main/micro/micro-clip
    sudo chmod +x /usr/local/bin/micro-clip

    echo "Micro installed successfully."
else
    echo "Micro is already installed. Skipping installation."
fi

# Theme and settings installation (always runs)
mkdir -p ~/.config/micro/colorschemes
curl -s -o ~/.config/micro/colorschemes/catppuccin-frappe-transparent.micro \
    https://raw.githubusercontent.com/Drarox/dotfiles/main/micro/colorschemes/catppuccin-frappe-transparent.micro
curl -s -o ~/.config/micro/settings.json \
    https://raw.githubusercontent.com/Drarox/dotfiles/main/micro/settings.json

echo "Micro settings and theme have been applied."
