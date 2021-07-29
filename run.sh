#!/bin/sh -eux

docker pull ghcr.io/rekgrpth/django.docker
docker volume create django
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
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
    --env LC_ADDRESS=ru_RU.UTF-8 \
    --env LC_IDENTIFICATION=ru_RU.UTF-8 \
    --env LC_MEASUREMENT=ru_RU.UTF-8 \
    --env LC_MONETARY=ru_RU.UTF-8 \
    --env LC_NAME=ru_RU.UTF-8 \
    --env LC_NUMERIC=ru_RU.UTF-8 \
    --env LC_PAPER=ru_RU.UTF-8 \
    --env LC_TELEPHONE=ru_RU.UTF-8 \
    --env LC_TIME=ru_RU.UTF-8 \
    --env PYTHONPATH="/home/app/billing:/home/app:/usr/local/lib/python2.7:/usr/local/lib/python2.7/lib-dynload:/usr/local/lib/python2.7/site-packages" \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname django \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --mount type=bind,source=/run/uwsgi,destination=/run/uwsgi \
    --mount type=bind,source=/var/log/uwsgi/django,destination=/var/log/uwsgi \
    --mount type=volume,source=django,destination=/home \
    --name django \
    --network name=docker \
    --restart always \
    ghcr.io/rekgrpth/django.docker runsvdir /etc/service
docker run \
    --detach \
    --env DJANGO_SETTINGS_MODULE="lk_settings" \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env LC_ADDRESS=ru_RU.UTF-8 \
    --env LC_IDENTIFICATION=ru_RU.UTF-8 \
    --env LC_MEASUREMENT=ru_RU.UTF-8 \
    --env LC_MONETARY=ru_RU.UTF-8 \
    --env LC_NAME=ru_RU.UTF-8 \
    --env LC_NUMERIC=ru_RU.UTF-8 \
    --env LC_PAPER=ru_RU.UTF-8 \
    --env LC_TELEPHONE=ru_RU.UTF-8 \
    --env LC_TIME=ru_RU.UTF-8 \
    --env PYTHONPATH="/home/app/billing/lk:/home/app/billing:/usr/local/lib/python2.7:/usr/local/lib/python2.7/lib-dynload:/usr/local/lib/python2.7/site-packages" \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname lk-django \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --mount type=bind,source=/var/log/uwsgi/lk-django,destination=/var/log/uwsgi \
    --mount type=bind,source=/run/uwsgi,destination=/run/uwsgi \
    --mount type=volume,source=django,destination=/home \
    --name lk-django \
    --network name=docker \
    --restart always \
    ghcr.io/rekgrpth/django.docker uwsgi --ini lk-django.ini
