#!/bin/sh

#docker build --tag rekgrpth/django . || exit $?
#docker push rekgrpth/django || exit $?
docker stop django
docker stop lk-django
docker rm django
docker rm lk-django
docker pull rekgrpth/django || exit $?
docker volume create django || exit $?
docker run \
    --add-host `hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --add-host cherry-`hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --add-host ldap.t72.ru:`getent hosts ldap.t72.ru | cut -d ' ' -f 1` \
    --detach \
    --env USER_ID=$(id -u) \
    --env GROUP_ID=$(id -g) \
    --env PYTHONPATH="/data/app:/data/app/billing" \
    --env DJANGO_SETTINGS_MODULE="billing.settings" \
    --hostname django \
    --name django \
    --publish 4322:4322 \
    --restart always \
    --volume django:/data \
    rekgrpth/django
docker run \
    --add-host `hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --add-host django-`hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --detach \
    --env USER_ID=$(id -u) \
    --env GROUP_ID=$(id -g) \
    --env PYTHONPATH="/data/app:/data/app/billing:/data/app/billing/lk" \
    --env DJANGO_SETTINGS_MODULE="lk_settings" \
    --hostname lk-django \
    --name lk-django \
    --publish 4323:4323 \
    --restart always \
    --volume django:/data \
    --workdir /data/app/billing/lk \
    rekgrpth/django uwsgi --ini /data/lk-django.ini
