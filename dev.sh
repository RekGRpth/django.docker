#!/bin/sh

#docker build --tag rekgrpth/django . || exit $?
#docker push rekgrpth/django || exit $?
docker pull rekgrpth/django || exit $?
docker volume create django || exit $?
docker network create --attachable --driver overlay docker || echo $?
docker stop django || echo $?
docker stop lk-django || echo $?
docker rm django || echo $?
docker rm lk-django || echo $?
docker run \
    --add-host ldap.t72.ru:$(getent hosts ldap.t72.ru | cut -d ' ' -f 1) \
    --detach \
    --env DJANGO_SETTINGS_MODULE="billing.settings" \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env PYTHONPATH="/home/app/billing:/home/app:/usr/local/lib/python2.7:/usr/local/lib/python2.7/lib-dynload:/usr/local/lib/python2.7/site-packages" \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname django \
    --name django \
    --network name=docker \
    --restart always \
    --volume /etc/certs:/etc/certs \
    --volume django:/home \
    rekgrpth/django uwsgi --ini django.ini
docker run \
    --detach \
    --env DJANGO_SETTINGS_MODULE="lk_settings" \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env PYTHONPATH="/home/app/billing/lk:/home/app/billing:/usr/local/lib/python2.7:/usr/local/lib/python2.7/lib-dynload:/usr/local/lib/python2.7/site-packages" \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname lk-django \
    --name lk-django \
    --network name=docker \
    --restart always \
    --volume /etc/certs:/etc/certs \
    --volume django:/home \
    rekgrpth/django uwsgi --ini lk-django.ini
