FROM rekgrpth/pdf
ADD django-autocomplete-1.0.dev49 "${HOME}/src/django-autocomplete-1.0.dev49"
ADD _fontdata.py "${HOME}/src/"
ADD fonts /usr/local/share/fonts
ARG PYTHON_VERSION=2.7
ENV GROUP=django \
    PYTHONIOENCODING=UTF-8 \
    PYTHONPATH="${HOME}/app:${HOME}/app/billing:/usr/local/lib/python${PYTHON_VERSION}:/usr/local/lib/python${PYTHON_VERSION}/lib-dynload:/usr/local/lib/python${PYTHON_VERSION}/site-packages" \
    USER=django
VOLUME "${HOME}"
RUN set -eux; \
    addgroup -S "${GROUP}"; \
    adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}"; \
    apk add --no-cache --virtual .build-deps \
        cairo-dev \
        cjson-dev \
        clang \
        curl \
        freetype-dev \
        gcc \
        gettext-dev \
        git \
        grep \
        jansson-dev \
        jpeg-dev \
        json-c-dev \
        libffi-dev \
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
        py2-setuptools \
        python2-dev \
        swig \
        talloc-dev \
        zlib-dev \
    ; \
    cd "${HOME}/src"; \
    git clone https://github.com/RekGRpth/pyhandlebars.git; \
    git clone https://github.com/RekGRpth/pyhtmldoc.git; \
    git clone https://github.com/RekGRpth/pymustach.git; \
    curl "https://bootstrap.pypa.io/pip/${PYTHON_VERSION}/get-pip.py" -o get-pip.py; \
    python2 get-pip.py --no-python-version-warning --no-cache-dir --ignore-installed --prefix /usr/local; \
    cd "${HOME}/src/django-autocomplete-1.0.dev49"; \
    python2 setup.py install --prefix=/usr/local; \
    cd "${HOME}/src/pyhandlebars"; \
    python2 setup.py install --prefix /usr/local; \
    cd "${HOME}/src/pyhtmldoc"; \
    python2 setup.py install --prefix /usr/local; \
    cd "${HOME}/src/pymustach"; \
    python2 setup.py install --prefix /usr/local; \
    cd "${HOME}"; \
    pip install --no-python-version-warning --no-cache-dir --ignore-installed --prefix /usr/local \
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
        PyYAML \
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
        xhtml2pdf \
        xlrd \
        xlwt==0.7.4 \
    ; \
    cd "${HOME}/src"; \
    cp -rf _fontdata.py "/usr/local/lib/python${PYTHON_VERSION}/site-packages/reportlab/pdfbase"; \
    cd "${HOME}"; \
    apk add --no-cache --virtual .django-rundeps \
        openssh-client \
        python2 \
        sshpass \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build-deps; \
    find / -type f -name "*.pyc" -delete; \
    find / -type f -name "*.a" -delete; \
    find / -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    mkdir -p /home/bp/python/mark5; \
    ln -fs /home/app /home/bp/python/mark5/cherry_django; \
    mkdir -p /usr/local/cherry; \
    ln -fs /home/app /usr/local/cherry/cherry_django; \
    grep -r "Helvetica" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/reportlab" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/xhtml2pdf" | cut -d ':' -f 1 | sort -u | grep -E '.+\.py$' | while read -r FILE; do sed -i "s|Helvetica|NimbusSans-Regular|g" "$FILE"; done; \
    grep -r "TimesNewRoman" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/reportlab" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/xhtml2pdf" | cut -d ':' -f 1 | sort -u | grep -E '.+\.py$' | while read -r FILE; do sed -i "s|TimesNewRoman|NimbusRoman-Regular|g" "$FILE"; done; \
    grep -r "Times New Roman" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/reportlab" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/xhtml2pdf" | cut -d ':' -f 1 | sort -u | grep -E '.+\.py$' | while read -r FILE; do sed -i "s|Times New Roman|NimbusRoman-Regular|g" "$FILE"; done; \
    grep -r "Times-Roman" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/reportlab" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/xhtml2pdf" | cut -d ':' -f 1 | sort -u | grep -E '.+\.py$' | while read -r FILE; do sed -i "s|Times-Roman|NimbusRoman-Regular|g" "$FILE"; done; \
    grep -r "Times-" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/reportlab" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/xhtml2pdf" | cut -d ':' -f 1 | sort -u | grep -E '.+\.py$' | while read -r FILE; do sed -i "s|Times-|NimbusRoman-|g" "$FILE"; done; \
    grep -r "Arial" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/reportlab" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/xhtml2pdf" | cut -d ':' -f 1 | sort -u | grep -E '.+\.py$' | while read -r FILE; do sed -i "s|Arial|NimbusSans-Regular|g" "$FILE"; done; \
    grep -r "Courier New" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/reportlab" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/xhtml2pdf" | cut -d ':' -f 1 | sort -u | grep -E '.+\.py$' | while read -r FILE; do sed -i "s|Courier New|NimbusMonoPS-Regular|g" "$FILE"; done; \
    grep -r "Courier" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/reportlab" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/xhtml2pdf" | cut -d ':' -f 1 | sort -u | grep -E '.+\.py$' | while read -r FILE; do sed -i "s|Courier|NimbusMonoPS-Regular|g" "$FILE"; done; \
    grep -r "/usr/share/fonts/dejavu" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/reportlab" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/xhtml2pdf" | cut -d ':' -f 1 | sort -u | grep -E '.+\.py$' | while read -r FILE; do sed -i "s|/usr/share/fonts/dejavu|/usr/local/share/fonts|g" "$FILE"; done; \
    grep -r "DEFAULT_CSS = \"\"\"" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/reportlab" "/usr/local/lib/python${PYTHON_VERSION}/site-packages/xhtml2pdf" | cut -d ':' -f 1 | sort -u | grep -E '.+\.py$' | while read -r FILE; do sed -i "s|font-weight:bold;|font-weight:bold;font-family: NimbusSans-Bold;|g" "$FILE"; \
    sed -i "s|font-weight: bold;|font-weight:bold;font-family: NimbusSans-Bold;|g" "$FILE"; \
    sed -i "s|font-style: italic;|font-style: italic;font-family: NimbusSans-Italic;|g" "$FILE"; \
    sed -i "/^DEFAULT_CSS/cfrom os import path, listdir\ndejavu = '/usr/local/share/fonts'\nfonts = {file.split('.')[0]: path.join(dejavu, file) for file in listdir(dejavu) if file.endswith('.ttf')}\nDEFAULT_CSS = '\\\n'.join(('@font-face { font-family: \"%s\"; src: \"%s\";%s%s }' % (name, file, ' font-weight: \"bold\";' if 'bold' in name.lower() else '', ' font-style: \"italic\";' if 'italic' in name.lower() or 'oblique' in name.lower() else '') for name, file in fonts.items())) + \"\"\"" "$FILE"; done; \
    echo done
