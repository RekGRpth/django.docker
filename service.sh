#!/bin/sh -ex

#docker build --tag rekgrpth/django .
#docker push rekgrpth/django
docker pull rekgrpth/django
docker volume create django
docker network create --attachable --driver overlay docker || echo $?
docker service rm django || echo $?
docker service rm lk-django || echo $?
docker service create \
    --env DJANGO_SETTINGS_MODULE="billing.settings" \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env PYTHONPATH="/home/app/billing:/home/app:/usr/local/lib/python2.7:/usr/local/lib/python2.7/lib-dynload:/usr/local/lib/python2.7/site-packages" \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname="{{.Service.Name}}-{{.Node.Hostname}}" \
    --mode global \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --mount type=bind,source=/run/uwsgi,destination=/run/uwsgi \
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
    --hostname="{{.Service.Name}}-{{.Node.Hostname}}" \
    --mode global \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --mount type=bind,source=/run/uwsgi,destination=/run/uwsgi \
    --mount type=volume,source=django,destination=/home \
    --name lk-django \
    --network name=docker \
    rekgrpth/django uwsgi --ini lk-django.ini
