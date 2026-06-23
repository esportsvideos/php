FROM composer:2.10.1@sha256:41959f55087549989efcdfe953977b64e98e07ca0d7532d7e4b7fe1a90cc4159 AS composer
FROM mlocati/php-extension-installer:2@sha256:bd9ea77afcbc8e55e58d55ca9a39153925367e972827d2f648c949fd0e44aaca AS php_ext_installer
FROM php:8.5.7-fpm-alpine3.23@sha256:bdc083e7b6acfb5eec64b5c85c134fe33cde8aa177da0d93fc46e43df2555b98 AS php_base

# COMPOSER
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
COPY --from=php_ext_installer /usr/bin/install-php-extensions /usr/local/bin/

# NATIVE
# hadolint ignore=DL3018
RUN apk add --update --no-cache \
        git \
        unzip \
    && install-php-extensions \
        redis \
        zip \
        intl \
        pdo_pgsql \
        opcache

# CONFIGS
COPY conf.d/symfony.ini $PHP_INI_DIR/conf.d/

# APPLICATION
WORKDIR /var/www
RUN chown -R www-data:www-data /var/www

FROM php_base AS php_prod

ENV APP_ENV=prod
RUN ln -s "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# CONFIGS
COPY conf.d/prod.ini $PHP_INI_DIR/conf.d/
COPY conf.d/zz-access-log.conf /usr/local/etc/php-fpm.d/
COPY conf.d/zz-log-buffering.conf /usr/local/etc/php-fpm.d/
COPY conf.d/zz-ping.conf /usr/local/etc/php-fpm.d/

# hadolint ignore=DL3018
RUN apk add --update --no-cache fcgi

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
    CMD SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET \
        cgi-fcgi -bind -connect 127.0.0.1:9000 | grep -q pong

USER www-data

FROM php_base AS php_dev
# root needed to execute chown and su-exec for dev environnement only.
# hadolint ignore=DL3002
USER root

# Configs
RUN ln -s "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY conf.d/xdebug.ini $PHP_INI_DIR/conf.d/

# hadolint ignore=DL3018
RUN apk add --update --no-cache su-exec \
    && install-php-extensions xdebug

# ENTRYPOINT
COPY --chmod=755 docker-entrypoint.dev.sh /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
