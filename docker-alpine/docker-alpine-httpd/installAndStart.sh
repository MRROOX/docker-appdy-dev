#!/bin/sh

if [ -n "$APPD_ENABLE" -a "$APPD_ENABLE" = '1' ]; then
    echo "INSTALLING APPDYNAMICS AGENT"
    /opt/appdynamics-php-agent-linux_x64/install.sh -e=/usr/lib/php7/modules/ --ignore-permissions -s -a=$APPD_ACCOUNTNAME@$APPD_ACCOUNTKEY $APPD_CONTROLLER $APPD_PORT $APPD_APP $APPD_TIER $APPD_NODE
    #/opt/appdynamics-php-agent-linux_x64/install.sh -e=/usr/lib/php7/modules/ --enable-cli -s -a=$APPD_ACCOUNTNAME@$APPD_ACCOUNTKEY $APPD_CONTROLLER $APPD_PORT $APPD_APP $APPD_TIER $APPD_NODE
    echo "VERIFYING CONNECTIVITY TO CONTROLLER"
    curl -k -v https://$APPD_CONTROLLER:$APPD_PORT
    php -r "echo 'test';"
fi

#/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

#!/bin/sh

# Exit on non defined variables and on non zero exit codes
set -eu

SERVER_ADMIN="${SERVER_ADMIN:-you@example.com}"
HTTP_SERVER_NAME="${HTTP_SERVER_NAME:-www.example.com}"
HTTPS_SERVER_NAME="${HTTPS_SERVER_NAME:-www.example.com}"
LOG_LEVEL="${LOG_LEVEL:-info}"
TZ="${TZ:-UTC}"
PHP_MEMORY_LIMIT="${PHP_MEMORY_LIMIT:-256M}"

echo 'Updating configurations'

# Change Server Admin, Name, Document Root
sed -i "s/ServerAdmin\ you@example.com/ServerAdmin\ ${SERVER_ADMIN}/" /etc/apache2/httpd.conf
sed -i "s/#ServerName\ www.example.com:80/ServerName\ ${HTTP_SERVER_NAME}/" /etc/apache2/httpd.conf
sed -i 's#^DocumentRoot ".*#DocumentRoot "/htdocs"#g' /etc/apache2/httpd.conf
sed -i 's#Directory "/var/www/localhost/htdocs"#Directory "/htdocs"#g' /etc/apache2/httpd.conf
sed -i 's#AllowOverride None#AllowOverride All#' /etc/apache2/httpd.conf

# Change TransferLog after ErrorLog
sed -i 's#^ErrorLog .*#ErrorLog "/dev/stderr"\nTransferLog "/dev/stdout"#g' /etc/apache2/httpd.conf
sed -i 's#CustomLog .* combined#CustomLog "/dev/stdout" combined#g' /etc/apache2/httpd.conf

# SSL DocumentRoot and Log locations
sed -i 's#^ErrorLog .*#ErrorLog "/dev/stderr"#g' /etc/apache2/conf.d/ssl.conf
sed -i 's#^TransferLog .*#TransferLog "/dev/stdout"#g' /etc/apache2/conf.d/ssl.conf
sed -i 's#^DocumentRoot ".*#DocumentRoot "/htdocs"#g' /etc/apache2/conf.d/ssl.conf
sed -i "s/ServerAdmin\ you@example.com/ServerAdmin\ ${SERVER_ADMIN}/" /etc/apache2/conf.d/ssl.conf
sed -i "s/ServerName\ www.example.com:443/ServerName\ ${HTTPS_SERVER_NAME}/" /etc/apache2/conf.d/ssl.conf

# Re-define LogLevel
sed -i "s#^LogLevel .*#LogLevel ${LOG_LEVEL}#g" /etc/apache2/httpd.conf

# Enable commonly used apache modules
sed -i 's/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/' /etc/apache2/httpd.conf
sed -i 's/#LoadModule\ deflate_module/LoadModule\ deflate_module/' /etc/apache2/httpd.conf
sed -i 's/#LoadModule\ expires_module/LoadModule\ expires_module/' /etc/apache2/httpd.conf

# Modify php memory limit and timezone
sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" /etc/php7/php.ini
sed -i "s#^;date.timezone =\$#date.timezone = \"${TZ}\"#" /etc/php7/php.ini

echo 'Running Apache'

httpd -D FOREGROUND
