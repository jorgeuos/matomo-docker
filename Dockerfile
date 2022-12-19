FROM php:8.1-fpm-alpine3.16
# From template:
# https://github.com/matomo-org/docker/blob/master/Dockerfile-alpine.template

# Set MATOMO_VERSION in envvars.conf file, so we only have it in one place.
# ENV MATOMO_VERSION 4.12.1

LABEL maintainer="me@jorgeuos.com"
LABEL name="jorgeuos/matomo"
LABEL version="1"
# LABEL matomo-version=$MATOMO_VERSION

ENV PHP_MEMORY_LIMIT=256M

RUN set -ex; \
	\
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		autoconf \
		freetype-dev \
		icu-dev \
		libjpeg-turbo-dev \
		libpng-dev \
		libzip-dev \
		openldap-dev \
		pcre-dev \
		procps \
		vim \
		# bash \
	; \
	\
	docker-php-ext-configure gd --with-freetype --with-jpeg; \
	docker-php-ext-configure ldap; \
	docker-php-ext-install -j "$(nproc)" \
		gd \
		bcmath \
		ldap \
		mysqli \
		opcache \
		pdo_mysql \
		zip \
	; \
	\
# pecl will claim success even if one install fails, so we need to perform each install separately
	pecl install APCu-5.1.21; \
	pecl install redis-5.3.6; \
	\
	docker-php-ext-enable \
		apcu \
		redis \
	; \
	rm -r /tmp/pear; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
		| tr ',' '\n' \
		| sort -u \
		| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --virtual .matomo-phpext-rundeps $runDeps; \
	apk del .build-deps

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini


# RUN set -ex; \
# 	apk add --no-cache --virtual .fetch-deps \
# 		gnupg \
# 	; \
# 	\
# 	curl -fsSL -o matomo.tar.gz \
# 		"https://builds.matomo.org/matomo-${MATOMO_VERSION}.tar.gz"; \
# 	curl -fsSL -o matomo.tar.gz.asc \
# 		"https://builds.matomo.org/matomo-${MATOMO_VERSION}.tar.gz.asc"; \
# 	export GNUPGHOME="$(mktemp -d)"; \
# 	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys F529A27008477483777FC23D63BB30D0E5D2C749; \
# 	gpg --batch --verify matomo.tar.gz.asc matomo.tar.gz; \
# 	gpgconf --kill all; \
# 	rm -rf "$GNUPGHOME" matomo.tar.gz.asc; \
# 	tar -xzf matomo.tar.gz -C /usr/src/; \
# 	rm matomo.tar.gz; \
# 	apk del .fetch-deps

COPY php.ini /usr/local/etc/php/conf.d/php-matomo.ini

COPY docker-entrypoint.sh /entrypoint.sh

# We get Matomo from a script so we only need version in one place.
COPY get-matomo.sh /var/www/setup/get-matomo.sh

# Get your free license key at:
# https://www.maxmind.com/en/geolite2/signup
COPY get-geolitedb.sh /var/www/setup/get-geolitedb.sh

# If you need some contrib plugins, found at:
# https://plugins.matomo.org/
COPY contrib-plugins.sh /var/www/setup/contrib-plugins.sh

# If you have a Matomo license key, you can use this script to fetch your premium plugins
# COPY premium-plugins.sh /var/www/setup/premium-plugins.sh

# If you have custom files, such as custom logo, etc.
COPY custom-files /var/www/setup/custom-files
COPY custom-script.sh /var/www/setup/custom-script.sh

# This is to ensure we get Matomo version and our license keyes in place.
COPY envvars.conf /var/www/setup/envvars.conf
COPY set-envvars.sh /var/www/setup/set-envvars.sh

RUN set -ex; \
	apk add --no-cache --upgrade bash rsync; \
	cd /var/www/setup/ \
	&& ./get-matomo.sh \
	&& ./get-geolitedb.sh \
	&& ./contrib-plugins.sh \
	# You need a valid license key for this script:
	# && ./premium-plugins.sh \
	&& ls -lah /var/www/setup/ \
	&& ls -lah /var/www/setup/custom-files \
	# If you have custom files you want to mount into your image
	&& ./custom-script.sh \
	# A hack to get files in place before they are mounted from entrypoint
	&& rsync -crlOt --no-owner --no-group --no-perms /var/www/setup/ /usr/src/matomo/

# WORKDIR is /var/www/html (inherited via "FROM php")
# "/entrypoint.sh" will populate it at container startup from /usr/src/matomo
VOLUME /var/www/html

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
