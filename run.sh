#!/bin/sh

#docker build --tag rekgrpth/django . || exit $?
#docker push rekgrpth/django || exit $?
docker stop django
docker stop lk-django
docker rm django
docker rm lk-django
docker pull rekgrpth/django || exit $?
docker volume create django || exit $?
docker network create my
docker run \
    --add-host ldap.t72.ru:$(getent hosts ldap.t72.ru | cut -d ' ' -f 1) \
    --detach \
    --env DJANGO_SETTINGS_MODULE="billing.settings" \
    --env GROUP_ID=$(id -g) \
    --env PYTHONPATH="/data/app:/data/app/billing" \
    --env USER_ID=$(id -u) \
    --hostname django \
    --link nginx:cherry-$(hostname -f) \
    --link nginx:$(hostname -f) \
    --name django \
    --network my \
    --restart always \
    --volume django:/data \
    rekgrpth/django
docker run \
    --detach \
    --env DJANGO_SETTINGS_MODULE="lk_settings" \
    --env GROUP_ID=$(id -g) \
    --env PYTHONPATH="/data/app:/data/app/billing:/data/app/billing/lk" \
    --env USER_ID=$(id -u) \
    --hostname lk-django \
    --link nginx:django-$(hostname -f) \
    --link nginx:$(hostname -f) \
    --name lk-django \
    --network my \
    --restart always \
    --volume django:/data \
    --workdir /data/app/billing/lk \
    rekgrpth/django uwsgi --ini /data/lk-django.ini
