#!/bin/bash
docker stop Portainer
docker rm Portainer
docker pull portainer/portainer-ce:lts
docker run -d -p "127.0.0.1:9443:9443" --name Portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts