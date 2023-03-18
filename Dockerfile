FROM alpine:latest

ARG MW_VERSION
ARG MW_PATCH_VERSION
ARG COMPOSER_HASH

RUN apk add --no-cache \
	php81 \
	php81-curl \
	php81-xml \
	php81-fpm \
	php81-ctype \
	php81-gd \
	php81-json \
	php81-mysqli \
	php81-pdo_mysql \
	php81-dom \
	php81-openssl \
	php81-iconv \
	php81-opcache \
	php81-intl \
	php81-common \
	php81-xmlreader \
	php81-phar \
	php81-mbstring \
	php81-session \
	php81-fileinfo \
	diffutils \
	git \
	&& apk add --no-cache --virtual=.build-dependencies wget ca-certificates 

RUN	\
	# Install composer
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php -r "if (hash_file('SHA384', 'composer-setup.php') === \"${COMPOSER_HASH}\") { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
	&& php -r "unlink('composer-setup.php');"

RUN \
	# Tweak configs
	sed -i \
	-e "s,expose_php = On,expose_php = Off,g" \
	-e "s,;cgi.fix_pathinfo=1,cgi.fix_pathinfo=0,g" \
	-e "s,post_max_size = 8M,post_max_size = 100M,g" \
	-e "s,upload_max_filesize = 2M,upload_max_filesize = 100M,g" \
	/etc/php81/php.ini \
	&& sed -i \
	-e "s,;daemonize = yes,daemonize = no,g" \
	-e "s,user = nobody,user = www,g" \
	-e "s,group = nobody,group = www,g" \
	-e "s,;chdir = /var/www,chdir = /var/www/mediawiki,g" \
	-e "s,;listen.owner = nobody,listen.owner = www,g" \
	-e "s,;listen.group = nobody,listen.group = www,g" \
	-e "s,listen = 127.0.0.1:9000,listen = 0.0.0.0:9000,g" \
	-e "s,;clear_env = no,clear_env = no,g" \
	-e "s,;php_admin_flag[log_errors] = on,php_admin_flag[log_errors] = on,g" \
	-e "s,;php_admin_value[error_log] = /var/log/fpm-php.www.log,php_admin_value[error_log] = /var/log/fpm.log,g" \
	-e "s,;catch_workers_output = yes,catch_workers_output = yes,g" \
	/etc/php81/php-fpm.d/www.conf \
	&& mkdir -p /var/www /var/log \
	&& cd /tmp \
	&& wget -nv https://releases.wikimedia.org/mediawiki/${MW_VERSION}/mediawiki-${MW_VERSION}.${MW_PATCH_VERSION}.tar.gz \
	&& tar -C /var/www -xzvf ./mediawiki*.tar.gz \
	&& mv /var/www/mediawiki* /var/www/mediawiki \
	&& rm -rf /tmp/mediawiki* \
	&& adduser -S -D -H www \
	&& chown -R www /var/www/mediawiki \
	&& chown -R www /var/log/ \ 
	&& apk del .build-dependencies

# Syntax highlight requires Python for Pygments. Uncomment the following line
# if you plan to use SyntaxHighlight (aka SyntaxHighlight_GeSHi) extension:
#RUN apk add --no-cache python3 && ln -s python3 /usr/bin/python

USER www

WORKDIR /var/www/mediawiki

EXPOSE 9000

ENTRYPOINT [ "php-fpm81", "-F" ]
