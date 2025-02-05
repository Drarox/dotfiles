#!/bin/bash

#Test if is runned in root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

echo "This script will configure a nginx container for reverse proxy"
read -p "Press [Enter] to continue ..."

echo "Create a stack named reverse with the following configuration:"
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/docker-compose.yml
read -p "Press [Enter] to continue when done ..."

read -p "Press [Enter] to configure /var/lib/docker/volumes/reverse_nginx_reverse_conf/_data ..."
cd /var/lib/docker/volumes/reverse_nginx_reverse_conf/_data
mkdir sites-available
cd sites-available
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/example
cd ..
mkdir sites-enabled
openssl dhparam -out dhparam.pem 2048
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/cloudflare
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/nginx.conf
cd conf.d
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/default.conf
cd ..

read -p "Press [Enter] to install and configure cerbot ..."
apt install certbot -y
mkdir snippets
cd snippets
curl -O https://raw.githubusercontent.com/Drarox/dotfiles/main/server/nginx-config/letsencrypt
cd ..

echo "To create a certificate, run the following command:"
echo "sudo certbot certonly --webroot -w /var/www/letsencrypt --agree-tos --no-eff-email --email name@domain.com -d domain.com --rsa-key-size 4096"
echo "And add the renew in the crontab:"
echo "42 1 * * 1 /usr/bin/certbot renew >> /var/log/le-renew.log"

read -p "Press [Enter] to restart the nginx container and finish ..."
docker restart Nginx_Reverse