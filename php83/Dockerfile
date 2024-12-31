FROM php:8.3-fpm

RUN apt-get update && \
    apt-get install -y \
      libzip-dev \
      libpng-dev \
      libicu-dev \
      libxml2-dev \
      unzip \
      curl \
      libonig-dev \
      libpq-dev \
      locales \
      locales-all && \
    docker-php-ext-install \
      mysqli \
      pgsql \
      zip \
      gd \
      intl \
      exif \
      soap \
      opcache \
      mbstring && \
    pecl channel-update pecl.php.net && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    /usr/local/bin/composer self-update

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN composer global config minimum-stability dev --no-interaction && \
    composer global config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true --no-interaction  && \
    composer global require moodlehq/moodle-cs --no-interaction  && \
    composer global update --no-interaction

ENV PATH="${PATH}:/root/.composer/vendor/bin"