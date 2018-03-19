#!/bin/sh

#docker build --tag rekgrpth/django . && \
#docker push rekgrpth/django
docker stop django
docker rm django
docker pull rekgrpth/django && \
docker volume create django && \
docker run \
    --add-host `hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --add-host ldap.t72.ru:`getent hosts ldap.t72.ru | cut -d ' ' -f 1` \
    --detach \
    --env USER_ID=$(id -u) \
    --env GROUP_ID=$(id -g) \
    --env PYTHONPATH="/data/django:/data/django/billing" \
    --env DJANGO_SETTINGS_MODULE="billing.settings" \
    --hostname django \
    --name django \
    --publish 4322:4322 \
    --volume django:/data \
    rekgrpth/django
