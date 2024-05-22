FROM php:8.2-apache AS base

# timezone environment
ENV TZ=UTC \
    # locale
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        git=1:2.39.2-1.1 \
        gosu=1.14-1+b6 \
        libicu-dev=72.1-3 \
        libonig-dev=6.9.8-1 \
        libfreetype6-dev=2.12.1+dfsg-5 \
        libjpeg62-turbo-dev=1:2.1.5-2 \
        libpng-dev=1.6.39-2 \
        libpq-dev=15.6-0+deb12u1 \
        libzip-dev=1.7.3-1+b1 \
        locales=2.36-9+deb12u7 \
        unzip=6.0-28 \
    && locale-gen en_US.UTF-8 \
    && localedef -f UTF-8 -i en_US en_US.UTF-8 \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        bcmath \
        gd \
        intl \
        pdo_mysql \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# apache configuration
COPY ./infra/docker/php-apache/000-default.conf /etc/apache2/sites-enabled/

# enable Apache modules
RUN mv /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled \
    && /bin/sh -c a2enmod rewrite

# install Node.js
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -O -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
        nodejs=18.19.0+dfsg-6~deb12u1 \
        npm=9.2.0~ds1-1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./infra/docker/php-apache/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "apache2-foreground" ]

FROM base AS development

COPY ./infra/docker/php-apache/php.development.ini /usr/local/etc/php/php.ini

FROM development AS development-xdebug

RUN pecl install xdebug && \
    docker-php-ext-enable xdebug

COPY ./infra/docker/php-apache/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

FROM base AS deploy

COPY ./infra/docker/php-apache/php.deploy.ini /usr/local/etc/php/php.ini
COPY ./src /workspace

RUN composer install -q -n --no-ansi --no-dev --no-scripts --no-progress --prefer-dist \
    && chmod -R 777 storage bootstrap/cache \
    && php artisan optimize:clear \
    && php artisan optimize \
    && npm install
