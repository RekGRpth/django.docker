FROM rekgrpth/gost
COPY django-autocomplete-1.0.dev49.tar.gz /tmp/
ENV GROUP=django \
    PYTHONIOENCODING=UTF-8 \
    USER=django
VOLUME "${HOME}"
RUN set -ex \
    && addgroup -S "${GROUP}" \
    && adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}" \
    && apk add --no-cache --virtual .build-deps \
        cairo-dev \
        gcc \
        jpeg-dev \
        libxml2-dev \
        libxslt-dev \
        linux-headers \
        make \
        musl-dev \
        openjpeg-dev \
        openldap-dev \
        pcre2-dev \
        pcre-dev \
        postgresql-dev \
        py2-pip \
        python-dev \
        zlib-dev \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --prefix /usr/local \
        appy==0.8.3 \
        celery==3.0.16 \
        decorator \
        Django==1.4.5 \
        django-auth-ldap==1.1.4 \
        django-bootstrap-toolkit==2.15.0 \
        django-celery==3.0.11 \
        django-crispy-forms==1.2.3 \
        django-dajax==0.9.2 \
        django-dajaxice==0.7 \
        django-debug-logging==0.4 \
        django-debug-toolbar==1.3.2 \
        django-disguise==0.0.1b \
        django-endless-pagination==2.0 \
        django-extensions==1.5.5 \
        django-indexer==0.3.0 \
        django-inplaceedit==1.4.1 \
        django-kombu==0.9.4 \
        django-paging==0.2.4 \
        django-picklefield==0.3.0 \
        Django-Select2==4.2.2 \
        django-simple-captcha==0.4.5 \
        django-social-auth==0.7.22 \
        django-social-auth-trello==1.0.3 \
        django-spaghetti-and-meatballs==0.1.1 \
        django-static-compiler==0.3.1 \
        django-supervisor==0.3.4 \
        django-tables2==1.0.4 \
        django-templatetag-sugar==0.1 \
        django-ticketing==0.7.4 \
        django-webodt==0.3.1 \
        html5lib==0.90 \
        httplib2 \
        ipaddr \
        ipaddress \
        ipython \
        kombu==2.5.7 \
        lxml \
        mongoengine==0.8.7 \
        netaddr \
        olefile \
        openpyxl==2.1.4 \
        paramiko==1.12.1 \
        passlib==1.6.2 \
        pexpect \
        pika==0.9.14 \
        Pillow \
        pisa==3.0.32 \
        psycopg2 \
        ptyprocess \
        puka==0.0.7 \
        pycairo \
        Pygments \
        PyJWT==1.4.0 \
        pyldap \
        pymongo==2.7 \
        pyPdf==1.13 \
        pysnmp \
        python-dateutil \
        reportlab==2.5 \
        requests \
        sh \
        six \
        suds==0.4 \
        uuid \
        uwsgi \
        uwsgidecorators==1.1.0 \
        wcwidth \
        wheel==0.24.0 \
        workdays==1.3 \
        xlrd \
        xlwt==0.7.4 \
    && cd /tmp \
    && tar -zxpf django-autocomplete-1.0.dev49.tar.gz \
    && cd django-autocomplete-1.0.dev49 \
    && python setup.py install \
    && cd / \
    && rm -f /tmp/django-autocomplete-1.0.dev49.tar.gz \
    && rm -rf /tmp/django-autocomplete-1.0.dev49 \
    && apk add --no-cache --virtual .django-rundeps \
        openssh-client \
        python \
        sshpass \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }') \
    && (strip /usr/local/bin/* /usr/local/lib/*.so || true) \
    && apk del --no-cache .build-deps
