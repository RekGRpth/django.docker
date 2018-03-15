FROM debian as deb-stage

MAINTAINER RekGRpth

RUN apt-get update --yes --quiet && \
    apt-get full-upgrade --yes --quiet && \
    apt-get install --yes --quiet --no-install-recommends \
        build-essential \
        ca-certificates \
        ipython \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        locales \
        nginx-full \
        python-dev \
        python-pip \
        python-setuptools \
        supervisor \
        uwsgi \
        uwsgi-plugin-python \
        zlib1g-dev \
        && \
    mkdir --parents /home/user && \
    groupadd --system user && \
    useradd --system --gid user --home-dir /home/user --shell /sbin/nologin user && \
    ln --force --symbolic /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime && \
    echo "Asia/Yekaterinburg" > /etc/timezone && \
    apt-get remove --quiet --auto-remove --yes && \
    apt-get clean --quiet --yes && \
    rm --recursive --force /var/lib/apt/lists/* && \
    chown -R user:user /home/user && \
    localedef --inputfile=ru_RU --force --charmap=UTF-8 --alias-file=/usr/share/locale/locale.alias ru_RU.UTF-8 && \
    rm --force /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default && \
    echo "daemon off;" >> /etc/nginx/nginx.conf

FROM deb-stage as pip-stage

ADD requirements.txt /home/user/
RUN pip install --requirement /home/user/requirements.txt

FROM pip-stage

ENV HOME /home/user
ENV LANG ru_RU.UTF-8
ENV USER_ID 999
ENV GROUP_ID 999
ENV PROCESSES auto

ADD nginx.conf /etc/nginx/sites-enabled/
ADD supervisord.conf /etc/supervisor/conf.d/
ADD uwsgi.ini /etc/uwsgi/apps-enabled/

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

WORKDIR $HOME/django

CMD ["/usr/bin/supervisord"]
