#!/bin/bash
set -e
if [ ! -z "${MONGO_PORT_27017_TCP_ADDR}" ] && [ ! -z "${MONGO_PORT_27017_TCP_PORT}" ]
then
    while ! exec 6<>/dev/tcp/${MONGO_PORT_27017_TCP_ADDR}/${MONGO_PORT_27017_TCP_PORT}; do
        echo "$(date) - still trying to connect to ${MONGO_PORT_27017_TCP_ADDR}/${MONGO_PORT_27017_TCP_PORT}"
        sleep 1
    done
    exec 6>&-
    exec 6<&-
fi
if [ ! -d /var/www/html/rubedo/ ];
then
    if [ ! -d /var/rubedo_sources ] && [ "${GITHUB_APIKEY}" != "**None**" ]; then
        git clone -b 3.1.x https://github.com/WebTales/rubedo.git /var/www/html/rubedo
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/var/www/html/rubedo
        cd /var/www/html/rubedo/
        php composer.phar config -g github-oauth.github.com "$GITHUB_APIKEY"
        mv /root/composer.extensions.json /var/www/html/rubedo/composer.extensions.json
        ./rubedo.sh
        cd
    else
        echo "coping Rubedo"
        cp -R /var/rubedo_sources /var/www/html/rubedo
    fi
    chmod -R 777 /var/www/html/rubedo/cache/
    chmod -R 777 /var/www/html/rubedo/public/captcha
    chmod -R 777 /var/www/html/rubedo/public/generate-image
    chmod -R 777 /var/www/html/rubedo/public/theme

    if [ ! -z "${USERNAME}" ] && [ ! -z "${PWDSUPERVISOR}" ]
    then
        sed -i 's#username = Username#username = '"$USERNAME"'#g' /etc/supervisord.conf
        sed -i 's#password = PwdSupervisor#password = '"$PWDSUPERVISOR"'#g' /etc/supervisord.conf
    fi

    mv /root/local.php /var/www/html/rubedo/config/autoload/local.php
    chmod  777 /var/www/html/rubedo/config/autoload/local.php

    sed -i 's#"fromEmailNotification" => ""#"fromEmailNotification" => "'"$EMAIL"'"#g' /var/www/html/rubedo/config/autoload/local.php

    /usr/sbin/httpd -k start
    curl 'http://localhost/install/index/define-languages' -H 'Pragma: no-cache' -H 'Origin: http://localhost' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: no-cache' -H 'Referer: http://localhost/install/index/define-languages' -H 'Cookie: zdt-hidden=0' -H 'Connection: keep-alive' -H 'X-FirePHP-Version: 0.0.6' --data 'defaultLanguage=en&buttonGroup%5BSubmit%5D=Submit' --compressed
    curl 'http://localhost/install/index/set-db-contents?doInsertGroups=1' -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://localhost/install/index/set-db-contents' -H 'Cookie: zdt-hidden=0' -H 'Connection: keep-alive' -H 'X-FirePHP-Version: 0.0.6' -H 'Cache-Control: no-cache' --compressed
    curl 'http://localhost/install/index/set-db-contents?doEnsureIndex=1' -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://localhost/install/index/set-db-contents?doInsertGroups=1' -H 'Cookie: zdt-hidden=0' -H 'Connection: keep-alive' -H 'X-FirePHP-Version: 0.0.6' -H 'Cache-Control: no-cache' --compressed
    curl 'http://localhost/install/index/set-db-contents?initContents=1' -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://localhost/install/index/set-db-contents?doEnsureIndex=1' -H 'Cookie: zdt-hidden=0' -H 'Connection: keep-alive' -H 'X-FirePHP-Version: 0.0.6' -H 'Cache-Control: no-cache' --compressed
    curl 'http://localhost/install/index/set-admin' -H 'Pragma: no-cache' -H 'Origin: http://localhost' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: no-cache' -H 'Referer: http://localhost/install/index/set-admin' -H 'Cookie: zdt-hidden=0' -H 'Connection: keep-alive' -H 'X-FirePHP-Version: 0.0.6' --data 'name=admin&login=admin&password=admin&confirmPassword=admin&email='"$EMAIL"'&buttonGroup%5BSubmit%5D=Submit' --compressed
    curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -H "Cache-Control: no-cache" -d 'data=%7B%22text%22%3A%22'"$DOMAIN_NAME"'%22%2C%22version%22%3A%22%22%2C%22alias%22%3A%22%22%2C%22description%22%3A%22%22%2C%22keywords%22%3A%22%22%2C%22defaultLanguage%22%3A%22en%22%2C%22languages%22%3A%5B%22en%22%5D%2C%22activeMessagery%22%3A%22%22%2C%22SMTPServer%22%3A%22%22%2C%22SMTPPort%22%3A%22%22%2C%22SMTPLogin%22%3A%22%22%2C%22SMTPPassword%22%3A%22%22%2C%22defaultEmail%22%3A%22%22%2C%22accessibilityLevel%22%3A%22%22%2C%22opquastLogin%22%3A%22%22%2C%22opquastPassword%22%3A%22%22%2C%22protocol%22%3A%5B%22HTTP%22%5D%2C%22filter%22%3A%22%22%2C%22theme%22%3A%22default%22%2C%22homePage%22%3A%22%22%2C%22lastUpdateTime%22%3Anull%2C%22createTime%22%3Anull%2C%22title%22%3A%22Your+Website%22%2C%22author%22%3A%22Powered+by+Rubedo%22%2C%22workspace%22%3A%22global%22%2C%22defaultSingle%22%3A%22%22%2C%22googleMapsKey%22%3A%22%22%2C%22googleAnalyticsKey%22%3A%22%22%2C%22disqusKey%22%3A%22%22%2C%22builtOnEmptySite%22%3Atrue%2C%22builtOnModelSiteId%22%3A%22%22%2C%22locStrategy%22%3A%22onlyOne%22%2C%22useBrowserLanguage%22%3Afalse%2C%22i18n%22%3A%7B%22en%22%3A%7B%22title%22%3A%22Your+Website%22%2C%22description%22%3A%22%22%2C%22author%22%3A%22Powered+by+Rubedo%22%7D%7D%2C%22locale%22%3A%22en%22%2C%22nativeLanguage%22%3A%22en%22%2C%22staticDomain%22%3A%22%22%2C%22recaptcha_public_key%22%3A%22%22%2C%22recaptcha_private_key%22%3A%22%22%2C%22enableECommerceFeatures%22%3Afalse%2C%22resources%22%3A%22%22%2C%22iframelyKey%22%3A%22%22%7D' http://localhost/install/index/setSite
else
    /usr/sbin/httpd -k start
fi
exec "$@"