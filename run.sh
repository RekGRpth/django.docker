#!/bin/sh

docker stop django && \
docker rm django && \
docker pull rekgrpth/django && \
docker volume create django && \
docker run \
    --add-host `hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --detach \
    --env USER_ID=$(id -u) \
    --env GROUP_ID=$(id -g) \
    --env PROCESSES=4 \
    --hostname django \
    --name django \
    --publish 3333:3333 \
    --volume /etc/certs/t72.crt:/etc/nginx/ssl/t72.crt:ro \
    --volume /etc/certs/t72.key:/etc/nginx/ssl/t72.key:ro \
    --volume django:/home/user \
    rekgrpth/django
