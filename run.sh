#!/bin/sh

#docker build --tag rekgrpth/django . || exit $?
#docker push rekgrpth/django || exit $?
docker stop django
docker stop lk-django
docker rm django
docker rm lk-django
docker pull rekgrpth/django || exit $?
docker volume create django || exit $?
docker network create --opt com.docker.network.bridge.name=docker docker
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
    --link nginx:cherry-$(hostname -f) \
    --link nginx:$(hostname -f) \
    --name django \
    --network docker \
    --restart always \
    --volume /etc/certs/$(hostname -d).crt:/etc/ssl/server.crt \
    --volume /etc/certs/$(hostname -d).key:/etc/ssl/server.key \
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
    --link nginx:django-$(hostname -f) \
    --link nginx:$(hostname -f) \
    --name lk-django \
    --network docker \
    --restart always \
    --volume /etc/certs/$(hostname -d).crt:/etc/ssl/server.crt \
    --volume /etc/certs/$(hostname -d).key:/etc/ssl/server.key \
    --volume django:/home \
    rekgrpth/django uwsgi --ini lk-django.ini
