FROM ubuntu:16.04
MAINTAINER Yury Bilenkis <adm@bilenkis.ru>

CMD /usr/bin/supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf

RUN NGINX_VERSION="1.9.15" \
    && curl -L -o /opt/nginx-$NGINX_VERSION.deb "http://nginx.org/packages/mainline/ubuntu/pool/nginx/n/nginx/nginx_$NGINX_VERSION-1~xenial_amd64.deb" \
    && dpkg -i /opt/nginx-$NGINX_VERSION.deb \
    && rm -rf /opt/nginx-$NGINX_VERSION.deb \
    && rm -rf /etc/nginx/conf.d/default

RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && sed -i -e 's|http://archive.ubuntu.com|http://mirror.yandex.ru|' /etc/apt/sources.list \
    && apt-get update -qq \
    && apt-get upgrade -qq \
    && apt-get install --no-install-recommends -qq \
        ca-certificates \
        cron \
        logrotate \
        gunicorn3 \
        python-setuptools \
        python3 \
        python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY etc /etc
RUN cd /var/www/app \
    && nginx -t \
    && pip3 install --disable-pip-version-check --no-cache-dir \
        -r /etc/requirements.txt \
    && pip3 freeze --disable-pip-version-check > /etc/pip-freeze.txt

COPY app /var/www/app
