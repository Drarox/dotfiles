#!/bin/bash

### Preliminarie tests
#Test if is runned in root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

#Test if system is ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo "This script can only be run on Ubuntu. Exiting..."
    exit 1
fi

### Infos
echo "This script will install and configure the following:"
echo " - Upgrade the system"
echo " - Install base tools : git, curl"
echo " - Install terminal : zsh, oh-my-zsh"
echo " - Install tools : cockpit, mc, micro, gdu"
echo " - Install docker with portainer ce"
echo " - Install ssh server and ufw"
echo " - Change ssh port and configure ufw for ssh, http and https"
echo " - Install and configure fail2ban"
echo " - Reboot"
read -p "Press [Enter] to continue ..."

### Variables
read -p "Enter current user name: " nonrootuser
read -p "Enter desired ssh port: " sshport

### Updates
read -p "Press [Enter] key to apt update & upgrade ..."
apt update && apt upgrade

### Install base tools
apt install curl -y
apt install git -y

### Terminal
read -p "Press [Enter] key to install zsh ..."
apt install zsh -y

read -p "Press [Enter] key to install oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
curl -o ~/.zshrc https://raw.githubusercontent.com/Drarox/dotfiles/main/.zshrc
#Install for non root user
sudo -u $nonrootuser bash <<EOF
sh -c "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
curl -o ~/.zshrc https://raw.githubusercontent.com/Drarox/dotfiles/main/.zshrc
EOF

### Tools
read -p "Press [Enter] key to install cockpit ..."
apt-get install cockpit -y

read -p "Press [Enter] key to install mc ..."
apt install mc -y
mkdir -p ~/.config/mc/
mkdir -p ~/.local/share/mc/skins
curl -o ~/.config/mc/ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/ini
curl -o ~/.config/mc/filehighlight.ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/filehighlight.ini
curl -o ~/.config/mc/panels.ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/panels.ini
curl -o ~/.local/share/mc/skins/onedark.ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/skins/onedark.ini
# Non-root user actions
sudo -u $nonrootuser bash <<EOF
mkdir -p ~/.config/mc/
mkdir -p ~/.local/share/mc/skins
curl -o ~/.config/mc/ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/ini
curl -o ~/.config/mc/filehighlight.ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/filehighlight.ini
curl -o ~/.config/mc/panels.ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/config/panels.ini
curl -o ~/.local/share/mc/skins/onedark.ini https://raw.githubusercontent.com/Drarox/dotfiles/main/mc/skins/onedark.ini
EOF

read -p "Press [Enter] key to install micro ..."
# global install for all users, registering with update-alternatives
cd /usr/bin
curl https://getmic.ro/r | sudo sh
cd ~
#Custom clipboard for tabby
curl -o /usr/local/bin/micro-clip https://raw.githubusercontent.com/Drarox/dotfiles/main/micro/micro-clip
chmod +x /usr/local/bin/micro-clip
#Theme and settings
mkdir -p ~/.config/micro/colorschemes
curl -o ~/.config/micro/colorschemes/catppuccin-frappe-transparent.micro https://raw.githubusercontent.com/Drarox/dotfiles/main/micro/colorschemes/catppuccin-frappe-transparent.micro
curl -o ~/.config/micro/settings.json https://raw.githubusercontent.com/Drarox/dotfiles/main/micro/settings.json
# Non-root user actions
sudo -u $nonrootuser bash <<EOF
mkdir -p ~/.config/micro/colorschemes
curl -o ~/.config/micro/colorschemes/catppuccin-frappe-transparent.micro https://raw.githubusercontent.com/Drarox/dotfiles/main/micro/colorschemes/catppuccin-frappe-transparent.micro
curl -o ~/.config/micro/settings.json https://raw.githubusercontent.com/Drarox/dotfiles/main/micro/settings.json
EOF

read -p "Press [Enter] key to install gdu ..."
add-apt-repository ppa:daniel-milde/gdu
apt-get update
apt-get install gdu -y

### Security
apt install ufw -y
apt install unattended-upgrades -y

### Install docker
read -p "Press [Enter] key to install docker ..."
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

curl -o /etc/docker/daemon.json https://raw.githubusercontent.com/Drarox/dotfiles/main/server/docker-daemon.json

#Install portainer ce
read -p "Press [Enter] key to install portainer ..."
docker volume create portainer_data
docker run -d -p "127.0.0.1:9443:9443" --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts
curl -o ~/upgrade-portainer-ce.sh https://raw.githubusercontent.com/Drarox/dotfiles/main/server/upgrade-portainer-ce.sh

### Change ssh port & enable ufw
read -p "Press [Enter] key to install ssh server ..."
apt install openssh-server
read -p "Press [Enter] key to change ssh port ..."
sed -i "s/#Port 22/Port $sshport/g" /etc/ssh/sshd_config
read -p "Please check if the port is correctly set :"
cat /etc/ssh/sshd_config | grep Port
read -p "Please add 2FA or Key-Based Authentication for security."

#Install and setup fail2ban
read -p "Press [Enter] key to install and configure fail2ban ..."
apt install fail2ban -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i "s/= ssh/= ssh,$sshport/g" /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl start fail2ban

#Configure ufw
read -p "Press [Enter] key to configure ufw for ssh, http and https ..."
ufw default deny incoming
ufw default allow outgoing
ufw allow $sshport
ufw allow 80
ufw allow 443
ufw enable

#Reboot
echo "Setup done. Please reboot."
read -p "Press [Enter] key to reboot ..."
read -p "Please connect to new ssh port if changed."
reboot
