#!/bin/bash

#Test if is runned in root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

### Variables
read -p "Enter current user name: " nonrootuser
read -p "Enter desired ssh port: " sshport

### Updates
read -p "Press [Enter] key to apt update & upgrade ..."
apt update && apt upgrade

### Terminal
read -p "Press [Enter] key to install zsh ..."
apt install zsh -y

read -p "Press [Enter] key to install oh-my-zsh on root ..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
#Download .zshrc
wget https://raw.githubusercontent.com/Drarox/dotfiles/main/.zshrc -O ~/.zshrc

#Install for non root user
read -p "Press [Enter] key to install oh-my-zsh on user ..."
su $nonrootuser
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
#Download .zshrc
wget https://raw.githubusercontent.com/Drarox/dotfiles/main/.zshrc -O ~/.zshrc
#Back to root
exit

### Install unattended-upgrades
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

#Install portainer ce
read -p "Press [Enter] key to install portainer ..."
docker volume create portainer_data
docker run -d -p "127.0.0.1:9443:9443" --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

### Change ssh port & enable ufw
read -p "Press [Enter] key to install ssh server ..."
apt install openssh-server
read -p "Press [Enter] key to change ssh port ..."
sed -i "s/#Port 22/Port $sshport/g" /etc/ssh/sshd_config
read -p "Please check if the port is correctly set :"
cat /etc/ssh/sshd_config | grep Port

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
read -p "Press [Enter] key to reboot ..."
read -p "Please connect to new ssh port if changed."
reboot










