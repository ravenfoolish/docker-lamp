FROM php:8.2-apache AS base

# timezone environment
ENV TZ=UTC \
    # locale
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Install PHP dependencies and extensions
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        locales \
        git \
        unzip \
        libzip-dev \
        libicu-dev \
        libonig-dev \
        zlib1g-dev \
        libpq-dev \
        vim \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libjpeg-dev \
        libpng-dev \
        gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8 \
    && localedef -f UTF-8 -i en_US en_US.UTF-8 \
    && docker-php-ext-install \
        intl \
        pdo_mysql \
        zip \
        bcmath \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

# apache configuration
ADD ./infra/docker/php-apache/000-default.conf /etc/apache2/sites-enabled/

# Enable Apache modules
RUN mv /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled
RUN /bin/sh -c a2enmod rewrite

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

COPY ./infra/docker/php-apache/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "apache2-foreground" ]

# Development stage: Includes Node.js
FROM base AS development

COPY ./infra/docker/php-apache/php.development.ini /usr/local/etc/php/php.ini

FROM development AS development-xdebug

RUN pecl install xdebug && \
    docker-php-ext-enable xdebug

COPY ./infra/docker/php-apache/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Deploy stage: Includes Node.js
FROM base AS deploy

COPY ./infra/docker/php-apache/php.deploy.ini /usr/local/etc/php/php.ini
COPY ./src /workspace

RUN composer install -q -n --no-ansi --no-dev --no-scripts --no-progress --prefer-dist \
    && chmod -R 777 storage bootstrap/cache \
    && php artisan optimize:clear \
    && php artisan optimize \
    && npm install
