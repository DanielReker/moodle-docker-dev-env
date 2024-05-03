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
    exif \
    soap \
    opcache


RUN pecl channel-update pecl.php.net
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug


ENV PHP_IDE_CONFIG 'serverName=moodle-docker-server'
RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.start_with_request = yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.client_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.log=/var/log/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.idekey = PHPSTORM" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

#COPY ./php.ini "$PHP_INI_DIR/php.ini"

#ENTRYPOINT [ "/usr/local/bin/php", "-S", "0.0.0.0:8000", "-t", "/usr/share/nginx/html/moodle/" ]