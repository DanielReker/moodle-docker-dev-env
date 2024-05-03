FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libicu-dev \
    libxml2-dev

RUN docker-php-ext-install \
    mysqli \
    zip \
    gd \
    intl \
    #xmlrpc \
    soap \
    opcache


# RUN pecl channel-update pecl.php.net && \
#     pecl install xdebug-2.8.1 && \
#     docker-php-ext-enable xdebug

COPY ./php.ini "$PHP_INI_DIR/php.ini"

ENTRYPOINT [ "/usr/local/bin/php", "-S", "0.0.0.0:8000", "-t", "/usr/share/nginx/html/moodle/" ]