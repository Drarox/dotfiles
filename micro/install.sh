#!/bin/sh

echo 'You can choose to install micro or just the theme and settings'

printf 'Install micro (y/N) ? '
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then 
    # global install for all users, registering with update-alternatives
    cd /usr/bin
    curl https://getmic.ro/r | sudo sh
    cd ~
    #Custom clipboard for tabby
    curl -o /usr/local/bin/micro-clip https://raw.githubusercontent.com/Drarox/dotfiles/main/micro/micro-clip
    chmod +x /usr/local/bin/micro-clip
fi

#Theme and settings
mkdir -p ~/.config/micro/colorschemes
curl -o ~/.config/micro/colorschemes/catppuccin-frappe-transparent.micro https://raw.githubusercontent.com/Drarox/dotfiles/main/micro/colorschemes/catppuccin-frappe-transparent.micro
curl -o ~/.config/micro/settings.json https://raw.githubusercontent.com/Drarox/dotfiles/main/micro/settings.json