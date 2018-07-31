FROM alpine

MAINTAINER RekGRpth

ADD entrypoint.sh /

COPY requirements.txt /tmp/
COPY django-autocomplete-1.0.dev49.tar.gz /tmp/

ENV HOME=/data \
    LANG=ru_RU.UTF-8 \
    TZ=Asia/Yekaterinburg \
    USER=uwsgi \
    GROUP=uwsgi \
    PYTHONIOENCODING=UTF-8 \
    PYTHONPATH=/data/app/billing

RUN apk add --no-cache \
        alpine-sdk \
        libcrypto1.0 \
        openldap-dev \
        openssl \
        py2-cairo \
        py2-dateutil \
        py2-decorator \
        py2-httplib2 \
        py2-ipaddress \
        py2-lxml \
        py2-netaddr \
        py2-olefile \
        py2-pexpect \
        py2-pillow \
        py2-pip \
        py2-psycopg2 \
        py2-ptyprocess \
        py2-pygments \
        py2-pyldap \
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
        tzdata \
        uwsgi-python \
    && pip install --upgrade pip \
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
        openldap-dev \
    && find -name "*.pyc" -delete \
    && chmod +x /entrypoint.sh \
    && usermod --home "${HOME}" "${USER}" \
    && sed -i '1iopenssl_conf = openssl_def' /etc/ssl/openssl.cnf \
    && echo "[openssl_def]" >> /etc/ssl/openssl.cnf \
    && echo "engines = engine_section" >> /etc/ssl/openssl.cnf \
    && echo "" >> /etc/ssl/openssl.cnf \
    && echo "[engine_section]" >> /etc/ssl/openssl.cnf \
    && echo "gost = gost_section" >> /etc/ssl/openssl.cnf \
    && echo "" >> /etc/ssl/openssl.cnf \
    && echo "[gost_section]" >> /etc/ssl/openssl.cnf \
    && echo "engine_id = gost" >> /etc/ssl/openssl.cnf \
    && echo "default_algorithms = ALL" >> /etc/ssl/openssl.cnf \
    && echo "CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet" >> /etc/ssl/openssl.cnf

ADD uuid.py /usr/lib/python2.7/

VOLUME  ${HOME}

WORKDIR ${HOME}/app/billing

ENTRYPOINT ["/entrypoint.sh"]

CMD [ "uwsgi", "--ini", "/data/django.ini" ]
