FROM ubuntu:20.04

# Env for UTF-8 language encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Env for deb conf
ENV DEBIAN_FRONTEND noninteractive

USER root
RUN apt-get update
RUN apt-get install nano curl locate nginx openssl supervisor php7.4 php7.4-cli php7.4-fpm php7.4-xmlreader php7.4-phar php7.4-ctype php7.4-opcache php7.4-common php7.4-gd php7.4-json php7.4-intl php7.4-mbstring php7.4-pgsql php7.4-pdo php7.4-xml php7.4-zip php7.4-tokenizer php7.4-curl php7.4-apcu -y

RUN adduser --home /home/efx_container_user --gecos "" --disabled-password --uid 1000 efx_container_user && \
  mkdir -p /home/efx_container_user/.m2 && \
  chown -R efx_container_user:efx_container_user /home/efx_container_user

# Create symlink so programs depending on `php` still function
#RUN ln -s /usr/bin/php7 /usr/bin/php

# Configure nginx
COPY efx-image/nginx/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY efx-image/php/fpm-config.conf /etc/php/7.4/fpm/php-fpm.conf
#COPY efx-image/php/php.ini /etc/php/7.4/fpm/custom.ini

# Configure supervisord
COPY efx-image/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the efx_container_user user
RUN chown -R efx_container_user:efx_container_user /var/www/html && \
  chown -R efx_container_user:efx_container_user /run && \
  chown -R efx_container_user:efx_container_user /var/lib/nginx && \
  chown -R efx_container_user:efx_container_user /var/log/nginx

# Switch to use a non-root user from here on


# Add application
WORKDIR /var/www/html
COPY src/ /var/www/html/
RUN chown efx_container_user:efx_container_user -R /var/www/html/

ADD appdynamics-php-agent-linux_x64/appdynamics-php-agent-x64-linux-22.1.0.14.tar.bz2 /opt/
RUN chown efx_container_user:efx_container_user -R /opt/appdynamics-php-agent-linux_x64/
RUN chmod 755 -R /opt/appdynamics-php-agent-linux_x64/
RUN chmod 777 /opt/appdynamics-php-agent-linux_x64/logs
RUN ls -l /opt/appdynamics-php-agent-linux_x64/
RUN chmod o+w /usr/lib/php/20190902
RUN chmod o+w /etc/php/7.4/cli/conf.d
ADD installAndStart.sh /usr/local/bin/installAndStart.sh
RUN chown efx_container_user:efx_container_user /usr/local/bin/installAndStart.sh
RUN chmod u+x /usr/local/bin/installAndStart.sh
# Expose the port nginx is reachable on
EXPOSE 8080

USER efx_container_user
RUN ls -l /opt/appdynamics-php-agent-linux_x64/

ENTRYPOINT ["/usr/local/bin/installAndStart.sh"]

