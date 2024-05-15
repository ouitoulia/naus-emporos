#
# NOTE: THIS IS A FORK https://github.com/docker-library/drupal/blob/master/10.2/php8.3/fpm-alpine3.19/Dockerfile
#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

# https://www.drupal.org/docs/system-requirements/php-requirements
FROM php:8.2-fpm-alpine3.19

# install the PHP extensions we need
RUN set -eux; \
	\
	apk add --no-cache --virtual .build-deps \
		coreutils \
		freetype-dev \
		libjpeg-turbo-dev \
		libpng-dev \
		libwebp-dev \
		libzip-dev \
# postgresql-dev is needed for https://bugs.alpinelinux.org/issues/3642
		postgresql-dev \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg=/usr/include \
		--with-webp \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		zip \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-network --virtual .drupal-phpexts-rundeps $runDeps; \
	apk del --no-network .build-deps

# Add git for apply patch to modules
RUN apk add --no-cache git

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/

# https://github.com/ouitoulia/diagraphe/releases
ENV OUITOULIA_VERSION 10.2.47

# https://github.com/docker-library/drupal/pull/259
# https://github.com/moby/buildkit/issues/4503
# https://github.com/composer/composer/issues/11839
# https://github.com/composer/composer/issues/11854
# https://github.com/composer/composer/blob/94fe2945456df51e122a492b8d14ac4b54c1d2ce/src/Composer/Console/Application.php#L217-L218
ENV COMPOSER_ALLOW_SUPERUSER 1

WORKDIR /opt/drupal
RUN set -eux; \
	export COMPOSER_HOME="$(mktemp -d)"; \
	composer create-project --no-interaction --no-install --no-cache "ouitoulia/diagraphe:$OUITOULIA_VERSION" ./; \
	rmdir /var/www/html; \
	ln -sf /opt/drupal/web /var/www/html; \
  composer --no-interaction require drush/drush --no-install; \
  composer --no-interaction install

RUN mkdir "web/assets-cache"; \
	chown -R www-data:www-data web/assets-cache; \
  mkdir "web/public-files"; \
	chown -R www-data:www-data web/public-files; \
  mkdir "private-files"; \
	chown -R www-data:www-data private-files; \
  mkdir "config"; \
	chown -R www-data:www-data config; \
  mkdir "tmp"; \
	chown -R www-data:www-data tmp; \
	# delete composer cache
	rm -rf "$COMPOSER_HOME"

COPY ./settings.php /opt/drupal/web/sites/default/
COPY ./settings.local.php /opt/drupal/web/sites/default/

ENV PATH=${PATH}:/opt/drupal/vendor/bin

# vim:set ft=dockerfile: