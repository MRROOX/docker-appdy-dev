FROM alpine:3.13

USER root

# RUN apk del musl

ENV GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc
ENV GLIBC_VERSION=2.26-r0

RUN set -ex && \
    apk --update add libstdc++ curl ca-certificates && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION}; \
        do curl -sSL ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib

RUN apk --no-cache add \
  wget \
  curl \
  nginx \
  php8 \
  php8-ctype \
  php8-curl \
  php8-dom \
  php8-fpm \
  php8-gd \
  php8-intl \
  php8-json \
  php8-mbstring \
  php8-mysqli \
  php8-opcache \
  php8-openssl \
  php8-phar \
  php8-session \
  php8-xml \
  php8-xmlreader \
  php8-zlib \
  php8-tokenizer \
  php8-pdo_pgsql \
  php8-pgsql \
  supervisor

# RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
# RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk
# RUN apk add glibc-2.34-r0.apk


# RUN cp /lib64/ld-linux-x86-64.so.2 /lib/
# RUN ls -l /lib/

#RUN ldd
RUN /usr/glibc-compat/sbin/ldconfig

RUN adduser --home /home/efx_container_user --gecos "" --disabled-password --uid 1000 efx_container_user && \
  mkdir -p /home/efx_container_user/.m2 && \
  chown efx_container_user:efx_container_user /home/efx_container_user -R && \
  chmod 4444 /etc/ssl/certs/ca-certificates.crt && \
  rm -rf /var/cache/apk

# Create symlink so programs depending on `php` still function
#RUN ln -s /usr/bin/php8 /usr/bin/php

# Configure nginx
COPY efx-image/nginx/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY efx-image/php/fpm-config.conf /etc/php8/php-fpm.d/www.conf
COPY efx-image/php/php.ini /etc/php8/conf.d/config.ini

# Configure supervisord
COPY efx-image/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chown efx_container_user.efx_container_user /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the efx_container_user user
RUN chown -R efx_container_user.efx_container_user /var/www/html && \
  chown -R efx_container_user.efx_container_user /run && \
  chown -R efx_container_user.efx_container_user /var/lib/nginx && \
  chown -R efx_container_user.efx_container_user /var/log/nginx

# Switch to use a non-root user from here on


# Add application
WORKDIR /var/www/html
COPY src/ /var/www/html/
RUN chown efx_container_user.efx_container_user -R /var/www/html/

# AppDynamics Integration
ADD appdynamics-php-agent-linux_x64/appdynamics-php-agent-x64-linux-22.1.0.14.tar.bz2 /opt/
RUN chown efx_container_user.efx_container_user -R /opt/appdynamics-php-agent-linux_x64/
RUN chmod 755 -R /opt/appdynamics-php-agent-linux_x64/
RUN chmod 777 /opt/appdynamics-php-agent-linux_x64/logs
RUN ls -l /opt/appdynamics-php-agent-linux_x64/
RUN chmod o+w /usr/lib/php8/modules
RUN chmod o+w /etc/php8/conf.d
ADD installAndStart.sh /usr/local/bin/installAndStart.sh
RUN chown efx_container_user.efx_container_user /usr/local/bin/installAndStart.sh
RUN chmod u+x /usr/local/bin/installAndStart.sh


# Expose the port nginx is reachable on
EXPOSE 8080
#USER efx_container_user

ENTRYPOINT ["/usr/local/bin/installAndStart.sh"]