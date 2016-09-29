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
		diffutils \
		git \
	&& rm -rf /var/cache/apk/* \
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

VOLUME /var/www/mediawiki

EXPOSE 9000

ENTRYPOINT ["php-fpm","-F"]
