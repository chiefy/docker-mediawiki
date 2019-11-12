FROM alpine:latest

ENV \
	COMPOSER_HASH=a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1 \
	MW_VERSION=1.33 \
	MW_PATCH_VERSION=1

RUN apk add --no-cache \
	php7 \
	php7-curl \
	php7-xml \
	php7-fpm \
	php7-ctype \
	php7-gd \
	php7-json \
	php7-mysqli \
	php7-pdo_mysql \
	php7-dom \
	php7-openssl \
	php7-iconv \
	php7-opcache \
	php7-intl \
	php7-mcrypt \
	php7-common \
	php7-xmlreader \
	php7-phar \
	php7-mbstring \
	php7-session \
	php7-fileinfo \
	diffutils \
	git \
	&& apk add --no-cache --virtual=.build-dependencies wget ca-certificates \
	# Install composer
	&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php -r "if (hash_file('SHA384', 'composer-setup.php') === \"${COMPOSER_HASH}\") { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
	&& php -r "unlink('composer-setup.php');" \
	# Tweak configs
	&& sed -i \
	-e "s,expose_php = On,expose_php = Off,g" \
	-e "s,;cgi.fix_pathinfo=1,cgi.fix_pathinfo=0,g" \
	-e "s,post_max_size = 8M,post_max_size = 100M,g" \
	-e "s,upload_max_filesize = 2M,upload_max_filesize = 100M,g" \
	/etc/php7/php.ini \
	&& sed -i \
	-e "s,;daemonize = yes,daemonize = no,g" \
	-e "s,user = nobody,user = www,g" \
	-e "s,;chdir = /var/www,chdir = /var/www/mediawiki,g" \
	-e "s,;listen.owner = nobody,listen.owner = www,g" \
	-e "s,;listen.group = nobody,listen.group = www,g" \
	-e "s,listen = 127.0.0.1:9000,listen = 0.0.0.0:9000,g" \
	-e "s,;clear_env = no,clear_env = no,g" \
	/etc/php7/php-fpm.d/www.conf \
	# forward logs to docker log collector
	&& ln -sf /dev/stderr /var/log/php7/error.log \
	&& mkdir -p /var/www \
	&& cd /tmp \
	&& wget -nv https://releases.wikimedia.org/mediawiki/${MW_VERSION}/mediawiki-${MW_VERSION}.${MW_PATCH_VERSION}.tar.gz \
	&& tar -C /var/www -xzvf ./mediawiki*.tar.gz \
	&& mv /var/www/mediawiki* /var/www/mediawiki \
	&& rm -rf /tmp/mediawiki* \
	&& adduser -S -D -H www \
	&& chown -R www /var/www/mediawiki \
	&& apk del .build-dependencies

# Syntax highlight requires Python for Pygments. Uncomment the following line
# if you plan to use SyntaxHighlight (aka SyntaxHighlight_GeSHi) extension:
#RUN apk add --no-cache python3 && ln -s python3 /usr/bin/python

USER www

WORKDIR /var/www/mediawiki

EXPOSE 9000

ENTRYPOINT ["php-fpm7", "-F"]
