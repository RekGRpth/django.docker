FROM debian:buster-slim

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
        python-cairo \
        python-celery \
#        python-html5lib \
        python-ipaddr \
        python-jwt \
#        python-ldap \
        python-dev \
        python-mongoengine \
        python-netaddr \
        python-openpyxl \
        python-paramiko \
        python-passlib \
        python-pika \
        python-pip \
        python-psycopg2 \
#        python-pypdf2 \
#        python-reportlab \
        python-requests \
        python-setuptools \
        python-suds \
        python-uwsgidecorators \
        python-wheel \
        python-xlwt \
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
    rm --force /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    echo "\"\\e[A\": history-search-backward" >> /etc/inputrc && \
    echo "\"\\e[B\": history-search-forward" >> /etc/inputrc

#FROM deb-stage as pip-stage

ADD requirements.txt /home/user/
RUN pip install --requirement /home/user/requirements.txt

COPY django-autocomplete-1.0.dev49.tar.gz /home/user/
RUN cd /home/user && tar -zxpf django-autocomplete-1.0.dev49.tar.gz && cd django-autocomplete-1.0.dev49 && python setup.py install

#FROM pip-stage

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

WORKDIR $HOME/django/billing

CMD ["/usr/bin/supervisord"]
