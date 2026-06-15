#
# NOTE: THIS IS A FORK https://github.com/docker-library/drupal/blob/master/10.5/php8.3/fpm-alpine3.22/Dockerfile
#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

# https://www.drupal.org/docs/system-requirements/php-requirements
FROM php:8.4-fpm-alpine3.23

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
# postgresql-dev is needed for https://bugs.alpinelinux.org/issues/3642 \
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
		pdo_mysql \
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

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Add git for apply patch to modules
RUN apk add --no-cache git patch bind-tools && \
    apk add --no-cache pcre-dev autoconf gcc make libc-dev $PHPIZE_DEPS

# Install redis extension
RUN pecl update-channels && \
    pecl install redis && \
    docker-php-ext-enable redis

# Install uploadprogress
RUN pecl install uploadprogress && \
    docker-php-ext-enable uploadprogress

# Install APCu
RUN pecl install apcu && \
    docker-php-ext-enable apcu

# Install AVIF in GD
# -- Runtime libs
RUN apk add --no-cache \
    libavif \
    aom-libs \
    libwebp \
    libjpeg-turbo \
    libpng \
    freetype

# -- Build deps for compiling gd with AVIF
RUN apk add --no-cache --virtual .gd-build-deps \
    libavif-dev \
    aom-dev \
    libwebp-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    freetype-dev

# -- Rebuild PHP GD with AVIF enabled
RUN docker-php-ext-configure gd \
      --with-freetype \
      --with-jpeg \
      --with-webp \
      --with-avif \
 && docker-php-ext-install -j"$(nproc)" gd

# Remove only gd build deps (keep runtime libs)
RUN apk del .gd-build-deps
# --- end AVIF support in GD ---

# Clean dev tools
RUN apk del autoconf gcc make libc-dev $PHPIZE_DEPS

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/

# https://github.com/ouitoulia/diagraphe/releases
ENV OUITOULIA_VERSION=10.6.5

# https://github.com/docker-library/drupal/pull/259
# https://github.com/moby/buildkit/issues/4503
# https://github.com/composer/composer/issues/11839
# https://github.com/composer/composer/issues/11854
# https://github.com/composer/composer/blob/94fe2945456df51e122a492b8d14ac4b54c1d2ce/src/Composer/Console/Application.php#L217-L218
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /opt/drupal
RUN set -eux; \
	export COMPOSER_HOME="$(mktemp -d)"; \
	composer create-project --no-interaction --no-install --no-cache "ouitoulia/diagraphe:$OUITOULIA_VERSION" ./; \
	rmdir /var/www/html; \
	ln -sf /opt/drupal/web /var/www/html; \
  composer --no-interaction require drush/drush --no-install; \
  composer --no-interaction install; \
# https://github.com/docker-library/drupal/pull/266#issuecomment-2273985526 \
  composer check-platform-reqs

RUN mkdir -p \
    config \
    patch \
    private-files \
    web/assets-cache \
    web/libraries \
    web/public-files \
    web/public-files/styles \
    web/public-files/styles/paragraphs_type_icon \
    web/sites/default/files/translations \
    tmp \
    tmp/translations

COPY ./settings.php /opt/drupal/web/sites/default/
COPY ./settings.local.php /opt/drupal/web/sites/default/

# Set permissions
RUN chgrp -R 0 /opt/drupal && \
    chown -R 0 /opt/drupal && \
    chmod -R g=u /opt/drupal && \
    chmod -R g-w /opt/drupal && \
    chmod -R g+rwX \
      /opt/drupal/config \
      /opt/drupal/private-files \
      /opt/drupal/web/assets-cache \
      /opt/drupal/web/public-files \
      /opt/drupal/web/sites/default/files/translations \
      /opt/drupal/tmp && \
    find /opt/drupal -type d -exec chmod g+s {} \; && \
    rm -rf "$COMPOSER_HOME"

ENV PATH=${PATH}:/opt/drupal/vendor/bin

# vim:set ft=dockerfile:
