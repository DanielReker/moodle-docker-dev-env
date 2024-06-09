FROM php:8.3-fpm

RUN apt-get update
RUN apt-get install -y libzip-dev
RUN apt-get install -y libpng-dev
RUN apt-get install -y libicu-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y unzip
RUN apt-get install -y curl
RUN apt-get install -y libonig-dev
RUN apt-get install -y libpq-dev
RUN apt-get install -y locales locales-all


RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pgsql
RUN docker-php-ext-install zip
RUN docker-php-ext-install gd
RUN docker-php-ext-install intl
RUN docker-php-ext-install exif
RUN docker-php-ext-install soap
RUN docker-php-ext-install opcache
RUN docker-php-ext-install mbstring


RUN pecl channel-update pecl.php.net
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug


RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN /usr/local/bin/composer self-update

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN composer global config minimum-stability dev --no-interaction
RUN composer global config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true --no-interaction
RUN composer global require moodlehq/moodle-cs --no-interaction
RUN composer global update --no-interaction

ENV PATH="${PATH}:/root/.composer/vendor/bin"
