FROM centos:6

ENV SSH_PASS="bitrix"
ENV TIMEZONE="Europe/Moscow"
COPY run.sh /

RUN curl http://repos.1c-bitrix.ru/yum/bitrix-env.sh > /tmp/bitrix-env.sh \
    && /bin/bash /tmp/bitrix-env.sh \
    && rm -f /tmp/bitrix-env.sh \
    && mv -f /etc/php.d/20-phar.ini.disabled /etc/php.d/20-phar.ini \
    && yum install -y \
        openssh-server \
        wget \
    # install composer
	&& wget https://raw.githubusercontent.com/composer/getcomposer.org/f3333f3bc20ab8334f7f3dada808b8dfbfc46088/web/installer -O - -q | php -- --quiet \
	&& mv composer.phar /usr/local/bin/composer \
	# executable entrypoint
	&& chmod +x /run.sh \
    && sed -i 's/MEMORY=$(free.*/MEMORY=$\{BVAT_MEM\:\=262144\}/g' /etc/init.d/bvat \
    && echo "bitrix:$SSH_PASS" | chpasswd \
    && cp -f /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && yum clean all

EXPOSE 80
EXPOSE 443
WORKDIR /home/bitrix/www
CMD ["/run.sh"]
