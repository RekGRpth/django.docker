FROM alpine:3.15
ADD bin /usr/local/bin
ENTRYPOINT [ "docker_entrypoint.sh" ]
ENV HOME=/home
MAINTAINER RekGRpth
WORKDIR "$HOME"
ADD django-autocomplete-1.0.dev49 "$HOME/src/django-autocomplete-1.0.dev49"
ADD fonts /usr/local/share/fonts
ADD service /etc/service
ARG DOCKER_PYTHON_VERSION=2.7
CMD [ "/etc/service/uwsgi/run" ]
ENV GROUP=django \
    PYTHONIOENCODING=UTF-8 \
    PYTHONPATH="$HOME/app:$HOME/app/billing:/usr/local/lib/python$DOCKER_PYTHON_VERSION:/usr/local/lib/python$DOCKER_PYTHON_VERSION/lib-dynload:/usr/local/lib/python$DOCKER_PYTHON_VERSION/site-packages" \
    USER=django
RUN set -eux; \
    ln -fs su-exec /sbin/gosu; \
    chmod +x /usr/local/bin/*.sh; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    addgroup -S "$GROUP"; \
    adduser -S -D -G "$GROUP" -H -h "$HOME" -s /sbin/nologin "$USER"; \
    apk add --no-cache --virtual .build \
        autoconf \
        automake \
        bison \
        cairo-dev \
        check-dev \
        cjson-dev \
        clang \
        cups-dev \
        curl \
        file \
        flex \
        fltk-dev \
        freetype-dev \
        g++ \
        gcc \
        gettext-dev \
        git \
        grep \
        jansson-dev \
        jpeg-dev \
        json-c-dev \
        libffi-dev \
        libgcrypt-dev \
        libpng-dev \
        libtool \
        libxml2-dev \
        libxslt-dev \
        linux-headers \
        lmdb-dev \
        make \
        musl-dev \
        openjpeg-dev \
        openldap-dev \
        pcre2-dev \
        pcre-dev \
        postgresql-dev \
        py2-setuptools \
        python2-dev \
        subunit-dev \
        swig \
#        talloc-dev \
        yaml-dev \
        zlib-dev \
    ; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    git clone -b master https://github.com/RekGRpth/htmldoc.git; \
    git clone -b master https://github.com/RekGRpth/mustach.git; \
#    git clone https://github.com/RekGRpth/pyhandlebars.git; \
    git clone https://github.com/RekGRpth/pyhtmldoc.git; \
    git clone https://github.com/RekGRpth/pymustach.git; \
    ln -fs libldap.a /usr/lib/libldap_r.a; \
    ln -fs libldap.so /usr/lib/libldap_r.so; \
    cd "$HOME/src/htmldoc"; \
    ./configure --without-gui; \
    cd "$HOME/src/htmldoc/data"; \
    make -j"$(nproc)" install; \
    cd "$HOME/src/htmldoc/fonts"; \
    make -j"$(nproc)" install; \
    cd "$HOME/src/htmldoc/htmldoc"; \
    make -j"$(nproc)" install; \
    cd "$HOME/src/mustach"; \
    make -j"$(nproc)" libs=single install; \
    curl "https://bootstrap.pypa.io/pip/$DOCKER_PYTHON_VERSION/get-pip.py" -o get-pip.py; \
    python2 get-pip.py --no-python-version-warning --no-cache-dir --ignore-installed --prefix /usr/local; \
    cd "$HOME/src/django-autocomplete-1.0.dev49" && pip install --no-cache-dir --prefix /usr/local .; \
#    cd "$HOME/src/pyhandlebars" && pip install --no-cache-dir --prefix /usr/local .; \
    cd "$HOME/src/pyhtmldoc" && pip install --no-cache-dir --prefix /usr/local .; \
    cd "$HOME/src/pymustach" && pip install --no-cache-dir --prefix /usr/local .; \
    cd "$HOME"; \
    pip install --no-python-version-warning --no-cache-dir --ignore-installed --prefix /usr/local \
        appy==0.8.3 \
        celery==3.0.16 \
        configparser \
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
        netaddr==0.9 \
        olefile \
        openpyxl==2.1.4 \
        paramiko==1.12.1 \
        passlib==1.6.2 \
        pexpect \
        pika==0.9.14 \
        Pillow \
#        pisa==3.0.32 \
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
        PyYAML==5.3 \
        reportlab==2.5 \
        requests \
        sh \
        six \
        suds==0.4 \
        supervisor \
        uuid \
        uwsgi \
        uwsgidecorators==1.1.0 \
        wcwidth \
        wheel==0.24.0 \
        workdays==1.3 \
        xhtml2pdf==0.2.5 \
        xlrd \
        xlwt==0.7.4 \
    ; \
    cd /; \
    apk add --no-cache --virtual .django \
        busybox-extras \
        busybox-suid \
        ca-certificates \
        musl-locales \
        openssh-client \
        python2 \
        runit \
        sed \
        shadow \
        sshpass \
        su-exec \
        tzdata \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | grep -v "^$" | grep -v -e libcrypto | sort -u | while read -r lib; do test -z "$(find /usr/local/lib -name "$lib")" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    find /usr -type f -name "*.pyc" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    chmod -R 0755 /etc/service; \
    mkdir -p /home/bp/python/mark5; \
    ln -fs /home/app /home/bp/python/mark5/cherry_django; \
    mkdir -p /usr/local/cherry; \
    ln -fs /home/app /usr/local/cherry/cherry_django; \
    ln -fs xhtml2pdf "/usr/local/lib/python$DOCKER_PYTHON_VERSION/site-packages/ho"; \
#    grep -r "DEFAULT_CSS = \"\"\"" "/usr/local/lib/python$DOCKER_PYTHON_VERSION/site-packages/reportlab" "/usr/local/lib/python$DOCKER_PYTHON_VERSION/site-packages/xhtml2pdf" | cut -d ':' -f 1 | sort -u | grep -E '.+\.py$' | while read -r FILE; do \
#        sed -i "/^DEFAULT_CSS/cfrom os import path, listdir\ndejavu = '/usr/local/share/fonts'\nfonts = {file.split('.')[0]: path.join(dejavu, file) for file in listdir(dejavu) if file.endswith('.ttf')}\nDEFAULT_CSS = '\\\n'.join(('@font-face { font-family: \"%s\"; src: \"%s\";%s%s }' % (name, file, ' font-weight: \"bold\";' if 'bold' in name.lower() else '', ' font-style: \"italic\";' if 'italic' in name.lower() or 'oblique' in name.lower() else '') for name, file in fonts.items())) + \"\"\"" "$FILE"; \
#    done; \
    echo done
