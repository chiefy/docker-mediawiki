FROM alpine:3.4

MAINTAINER Christopher 'Chief' Najewicz <chief@beefdisciple.com>

ENV MEDIAWIKI_DL=https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.1.tar.gz

ADD $MEDIAWIKI_DL /tmp/

RUN \
	apk update \
	&& apk add --update \
		php5 \
		php5-curl \
		php5-xml \
		php5-fpm \
		php5-ctype \
		php5-gd \
		php5-json \
		php5-mysqli \
		php5-pdo_mysql \
		php5-dom \
		php5-openssl \
		php5-iconv \
		php5-xcache \
		php5-intl \
		php5-mcrypt \
		php5-common \
		php5-xmlreader \
		php5-phar \
		diffutils \
		git \
	&& rm -rf /var/cache/apk/* \
	# Install composer
	&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
	&& php -r "unlink('composer-setup.php');" \
	# Tweak configs
	&& sed -i \
		-e "s,expose_php = On,expose_php = Off,g" \
		-e "s,;cgi.fix_pathinfo=1,cgi.fix_pathinfo=0,g" \
		-e "s,post_max_size = 8M,post_max_size = 100M,g" \
		-e "s,upload_max_filesize = 2M,upload_max_filesize = 100M,g" \
		/etc/php5/php.ini \
	&& sed -i \
		-e "s,;daemonize = yes,daemonize = no,g" \
		-e "s,user = nobody,user = www,g" \
		-e "s,;chdir = /var/www,chdir = /var/www/mediawiki,g" \
		-e "s,;listen.owner = nobody,listen.owner = www,g" \
		-e "s,;listen.group = nobody,listen.group = www,g" \
		-e "s,listen = 127.0.0.1:9000,listen = 0.0.0.0:9000,g" \
		-e "s,;clear_env = no,clear_env = no,g" \
		/etc/php5/php-fpm.conf \
	&& sed -i "s,;extension=xcache.so,extension=xcache.so," /etc/php5/conf.d/xcache.ini \
	# forward logs to docker log collector
	&& ln -sf /dev/stdout /var/log/php-fpm.log \
	&& mkdir -p /var/www \
	&& cd /tmp \
	&& tar -C /var/www -xzvf ./mediawiki*.tar.gz \
	&& mv /var/www/mediawiki* /var/www/mediawiki \
	&& rm -rf /tmp/mediawiki* \
	&& adduser -S -D -H www \
	&& chown -R www /var/www/mediawiki

USER www

WORKDIR /var/www/mediawiki

EXPOSE 9000

ENTRYPOINT ["php-fpm","-F"]
