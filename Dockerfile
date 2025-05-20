ARG ALPINE_VERSION=3.21
ARG COMPOSER_VERSION=2.8.8
ARG PHP_VERSION=8.4.6

FROM composer:${COMPOSER_VERSION} AS composer
FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS php_prod

# ENV & ARG
ENV APP_ENV=prod
ENV PHPIZE_DEPS="\
	autoconf \
	dpkg-dev \
	dpkg \
	file \
	g++ \
	gcc \
	libc-dev \
	make \
	pkgconf \
	re2c"

# COMPOSER
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# NATIVE
# hadolint ignore=DL3018
RUN apk add --update --no-cache \
        git \
        unzip \
        libzip-dev \
        libpq-dev \
        icu-dev \
        icu-data-en \
        linux-headers \
	&& apk add --no-cache --virtual .build-deps \
      $PHPIZE_DEPS \
      zlib-dev \
    && pecl install redis \
	&& docker-php-ext-install \
      zip \
      intl \
      exif \
      pdo_pgsql \
	&& apk del .build-deps

# CONFIGS
RUN ln -s "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY conf.d/symfony.ini $PHP_INI_DIR/conf.d/
COPY conf.d/prod.ini $PHP_INI_DIR/conf.d/

# APPLICATION
WORKDIR /var/www

RUN chown -R www-data:www-data /var/www
USER www-data

FROM php_prod AS php_dev
# root needed to execute chown and su-exec for dev environnement only.
# hadolint ignore=DL3002
USER root
ENV APP_ENV=dev

# Configs
RUN unlink "$PHP_INI_DIR/php.ini" \
    && ln -s "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    && rm "$PHP_INI_DIR/conf.d/prod.ini"

COPY conf.d/xdebug.ini $PHP_INI_DIR/conf.d/

# hadolint ignore=DL3018,SC2086
RUN apk add --update --no-cache su-exec \
	&& apk add --no-cache --virtual .build-deps \
      $PHPIZE_DEPS \
      linux-headers \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del .build-deps

# ENTRYPOINT
COPY docker-entrypoint.dev.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
