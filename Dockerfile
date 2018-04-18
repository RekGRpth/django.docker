FROM alpine

MAINTAINER RekGRpth

COPY requirements.txt /tmp/
COPY django-autocomplete-1.0.dev49.tar.gz /tmp/

RUN apk add --no-cache \
        alpine-sdk \
#        freetype-dev \
#        jpeg \
#        jpeg-dev \
#        lcms2 \
#        lcms2-dev \
#        libffi \
#        libffi-dev \
#        libjpeg-turbo \
#        libxml2 \
#        libxml2-dev \
#        libxslt \
#        libxslt-dev \
#        openjpeg \
#        openjpeg-dev \
#        openldap \
        openldap-dev \
        py2-cairo \
        py2-dateutil \
        py2-decorator \
        py2-httplib2 \
        py2-ipaddress \
        py2-lxml \
        py2-netaddr \
        py2-olefile \
#        py2-paramiko \
        py2-pexpect \
        py2-pillow \
        py2-pip \
        py2-psycopg2 \
        py2-ptyprocess \
        py2-pygments \
        py2-pyldap \
#        py2-pypdf2 \
#        py2-reportlab \
        py2-requests \
        py2-six \
        py2-snmp \
        py2-wcwidth \
        py-ipaddr \
        py-setuptools \
        python \
        python-dev \
        shadow \
        su-exec \
#        tiff \
#        tiff-dev \
        tzdata \
        uwsgi-python \
#        zlib \
#        zlib-dev \
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
#        freetype-dev \
#        jpeg-dev \
#        lcms2-dev \
#        libffi-dev \
#        libxml2-dev \
#        libxslt-dev \
#        openjpeg-dev \
        openldap-dev \
#        py2-pip \
#        python-dev \
#        tiff-dev \
#        zlib-dev \
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

CMD [ "uwsgi", "--ini", "/data/django.ini" ]
