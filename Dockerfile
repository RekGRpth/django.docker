FROM alpine

MAINTAINER RekGRpth

COPY requirements.txt /tmp/
COPY django-autocomplete-1.0.dev49.tar.gz /tmp/

RUN apk add --no-cache \
        alpine-sdk \
        freetype-dev \
        jpeg-dev \
        lcms2-dev \
        libffi-dev \
        libxml2-dev \
        libxslt \
        libxslt-dev \
        openjpeg-dev \
        openldap-dev \
        py2-cairo \
        py2-dateutil \
        py2-pip \
        py2-psycopg2 \
        py-setuptools \
        python \
        python-dev \
        shadow \
        su-exec \
        tiff-dev \
        tzdata \
        uwsgi-python \
        zlib-dev \
    && pip install --no-cache-dir --requirement /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt \
    && cd /tmp \
    && tar -zxpf django-autocomplete-1.0.dev49.tar.gz \
    && cd django-autocomplete-1.0.dev49 \
    && python setup.py install \
    && cd / \
    && rm -f /tmp/django-autocomplete-1.0.dev49.tar.gz \
    && rm -rf /tmp/django-autocomplete-1.0.dev49 \
    && apk del \
        alpine-sdk \
        freetype-dev \
        jpeg-dev \
        lcms2-dev \
        libffi-dev \
        libxml2-dev \
        libxslt-dev \
        openjpeg-dev \
        openldap-dev \
        py2-pip \
        python-dev \
        tiff-dev \
        zlib-dev \
    && find -name "*.pyc" -delete

ADD uuid.py /usr/lib/python2.7/

ENV HOME=/data \
    LANG=ru_RU.UTF-8 \
    TZ=Asia/Yekaterinburg \
    USER=uwsgi \
    GROUP=uwsgi \
    PYTHONIOENCODING=UTF-8

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh && usermod --home "${HOME}" "${USER}"
ENTRYPOINT ["/entrypoint.sh"]

VOLUME  ${HOME}
WORKDIR ${HOME}/app/billing

CMD [ "uwsgi", "--ini", "/data/uwsgi.ini" ]
