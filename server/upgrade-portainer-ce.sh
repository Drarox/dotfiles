#!/bin/bash
docker stop portainer
docker rm portainer
docker pull portainer/portainer-ce:lts
docker run -d -p "127.0.0.1:9443:9443" --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts