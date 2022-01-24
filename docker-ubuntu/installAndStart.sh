#!/bin/sh

if [ -n "$APPD_ENABLE" -a "$APPD_ENABLE" = '1' ]; then
    echo "INSTALLING APPDYNAMICS AGENT"
    chmod 777 /opt/appdynamics-php-agent-linux_x64/logs
    /opt/appdynamics-php-agent-linux_x64/install.sh -e=/usr/lib/php/20190902 -i=/etc/php/7.4/cli/conf.d --enable-cli -s -a=$APPD_ACCOUNTNAME@$APPD_ACCOUNTKEY $APPD_CONTROLLER $APPD_PORT $APPD_APP $APPD_TIER $APPD_NODE
    echo "VERIFYING CONNECTIVITY TO CONTROLLER"
    #curl -k -v https://$APPD_CONTROLLER:$APPD_PORT
    php -r "echo 'test';"
fi

#service php7.4-fpm start
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf