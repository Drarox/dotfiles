#!/bin/bash

#Test if is runned in root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

echo "This script will configure a nginx container for reverse proxy."
echo "Docker needs to be installed and running."
read -p "Press [Enter] to continue ..."

echo "Create a stack named reverse with the following configuration:"
curl -s https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/docker-compose.yml
read -p "Press [Enter] to continue when done ..."

read -p "Press [Enter] to configure /var/lib/docker/volumes/reverse_nginx_reverse_conf/_data ..."
cd /var/lib/docker/volumes/reverse_nginx_reverse_conf/_data || { echo "Error: Volume not found!" >&2; exit 1; }
mkdir sites-available
cd sites-available
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/example
cd ..
mkdir sites-enabled
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/cloudflare
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/nginx.conf
cd conf.d # Default
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/00‑catchall.conf
cd ..
mkdir ssl # Create self signed certificates for 00‑catchall.conf
cd ssl
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout default.key -out default.crt
cd ..
mkdir snippets
cd snippets
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/snippets/letsencrypt
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/snippets/proxy-params.conf
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/snippets/websocket.conf
cd ..

read -p "Press [Enter] to install and configure cerbot ..."
apt install certbot -y
#Add crontab to renew certificates
(crontab -l 2>/dev/null; echo "30 1 * * 1 /usr/bin/certbot renew >> /var/log/le-renew.log") | crontab -
# Certbot hook to reload nginx automatically:
echo 'deploy-hook = docker exec Nginx_Reverse /usr/sbin/nginx -s reload' | sudo tee -a /etc/letsencrypt/cli.ini

echo "To create a certificate, run the following command:"
echo "sudo certbot certonly --webroot -w /var/www/letsencrypt --agree-tos --no-eff-email --email name@domain.com -d domain.com"

read -p "Press [Enter] to restart the nginx container and finish ..."
docker restart Nginx_Reverse
