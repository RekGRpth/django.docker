#!/bin/sh

docker build --tag rekgrpth/django . && \
docker push rekgrpth/django && \
docker stop django
docker rm django
docker pull rekgrpth/django && \
docker volume create django && \
docker run \
    --add-host `hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --detach \
    --env DJANGO_SETTINGS_MODULE="billing.settings" \
    --env USER_ID=$(id -u) \
    --env GROUP_ID=$(id -g) \
    --env PROCESSES=4 \
    --env PYTHONIOENCODING=UTF-8 \
    --env PYTHONPATH="$PYTHONPATH:/home/user/django:/home/user/django/billing" \
    --hostname django \
    --name django \
    --publish 3333:3333 \
    --volume /etc/certs/t72.crt:/etc/nginx/ssl/t72.crt:ro \
    --volume /etc/certs/t72.key:/etc/nginx/ssl/t72.key:ro \
    --volume django:/home/user \
    rekgrpth/django
