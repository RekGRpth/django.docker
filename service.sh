#!/bin/sh

#docker build --tag rekgrpth/django . || exit $?
#docker push rekgrpth/django || exit $?
docker pull rekgrpth/django || exit $?
docker volume create django || exit $?
docker network create --attachable --driver overlay docker || echo $?
docker service create \
    --env DJANGO_SETTINGS_MODULE="billing.settings" \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env PYTHONPATH="/home/app/billing:/home/app:/usr/local/lib/python2.7:/usr/local/lib/python2.7/lib-dynload:/usr/local/lib/python2.7/site-packages" \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname django \
    --mount type=bind,source=/etc/certs,destination=/etc/certs \
    --mount type=volume,source=django,destination=/home \
    --name django \
    --network name=docker \
    rekgrpth/django uwsgi --ini django.ini
docker service create \
    --env DJANGO_SETTINGS_MODULE="lk_settings" \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env PYTHONPATH="/home/app/billing/lk:/home/app/billing:/usr/local/lib/python2.7:/usr/local/lib/python2.7/lib-dynload:/usr/local/lib/python2.7/site-packages" \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname lk-django \
    --mount type=bind,source=/etc/certs,destination=/etc/certs \
    --mount type=volume,source=django,destination=/home \
    --name lk-django \
    --network name=docker \
    rekgrpth/django uwsgi --ini lk-django.ini
