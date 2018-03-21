FROM debian:buster-slim

MAINTAINER RekGRpth

RUN apt-get update --yes --quiet \
    && apt-get full-upgrade --yes --quiet \
    && apt-get install --yes --quiet --no-install-recommends \
        build-essential \
        ipython \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        locales \
        python-cairo \
        python-dev \
        python-pip \
        python-psycopg2 \
        python-setuptools \
        uwsgi \
        uwsgi-plugin-python \
        zlib1g-dev \
    && ln --force --symbolic /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime \
    && echo "Asia/Yekaterinburg" > /etc/timezone \
    && apt-get remove --quiet --auto-remove --yes \
    && apt-get clean --quiet --yes \
    && rm --recursive --force /var/lib/apt/lists/* \
    && echo "\"\\e[A\": history-search-backward" >> /etc/inputrc \
    && echo "\"\\e[B\": history-search-forward" >> /etc/inputrc \
    && find -name "*.pyc" -delete

COPY requirements.txt /tmp/
RUN pip install --requirement /tmp/requirements.txt \
    && rm --force /tmp/requirements.txt \
    && find -name "*.pyc" -delete

COPY django-autocomplete-1.0.dev49.tar.gz /tmp/
RUN cd /tmp \
    && tar -zxpf django-autocomplete-1.0.dev49.tar.gz \
    && cd django-autocomplete-1.0.dev49 \
    && python setup.py install \
    && rm --force /tmp/django-autocomplete-1.0.dev49.tar.gz \
    && find -name "*.pyc" -delete

RUN mkdir --parents /data \
    && groupadd --system uwsgi \
    && useradd --system --gid uwsgi --home-dir /data --shell /sbin/nologin uwsgi \
    && chown -R uwsgi:uwsgi /data

ADD uuid.py /usr/lib/python2.7/

ENV HOME=/data \
    LANG=ru_RU.UTF-8 \
    PYTHONIOENCODING=UTF-8

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

VOLUME /data
WORKDIR /data/django/billing

CMD [ "uwsgi", "--ini", "/data/uwsgi.ini" ]
