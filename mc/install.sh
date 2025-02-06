#!/bin/bash

apt install mc -y
mkdir -p ~/.config/mc/
mkdir -p ~/.local/share/mc/skins
curl -o ~/.config/mc/ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/ini
curl -o ~/.config/mc/filehighlight.ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/filehighlight.ini
curl -o ~/.config/mc/panels.ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/panels.ini
curl -o ~/.local/share/mc/skins/onedark.ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/skins/onedark.ini