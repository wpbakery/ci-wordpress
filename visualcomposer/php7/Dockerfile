FROM php:7.3-apache

ENV WP_TESTS_DIR /opt/wp-tests
ENV WP_TESTS_ABSPATH /var/www/html/
ENV WP_TESTS_DOMAIN localhost

COPY wp-tests-8.0.1.tar.gz /opt

RUN rm /etc/apt/preferences.d/no-debian-php

# Install dotdeb repo, PHP, composer and selected extensions
RUN apt-get update \
    && apt-get install -y curl gnupg2 \
    && echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list \
    && curl -sS https://www.dotdeb.org/dotdeb.gpg | apt-key add - \
    && apt-get update \
    && apt-get -y --no-install-recommends install php7.3-cli php7.3-fpm php7.3-dom php7.3-mbstring php7.3-apcu php7.3-apcu-bc php7.3-curl php7.3-gd php7.3-zip php7.3-json php7.3-opcache php7.3-readline \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && cp /etc/php/7.3/fpm/php.ini $PHP_INI_DIR \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && pecl install -o -f xdebug \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20180731/xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini

# POST and max upload sizes on php.ini
RUN sed -i "/upload_max_filesize = .*/c\upload_max_filesize = 200M" $PHP_INI_DIR/php.ini \
    && sed -i "/post_max_size = .*/c\post_max_size = 200M" $PHP_INI_DIR/php.ini \
    && sed -i "/memory_limit = .*/c\memory_limit = 256M" $PHP_INI_DIR/php.ini

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install php7.3-mysql \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN tar -zxvf /opt/wp-tests-8.0.1.tar.gz -C /opt

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y default-mysql-server default-libmysqlclient-dev --no-install-recommends \
    && apt-get install -y git zip \
    && rm -rf /var/lib/apt/lists/*

# Install wp-tests
RUN tar -zxvf /opt/wp-tests-8.0.1.tar.gz -C /opt

# Install GO (required for phpgrep)
RUN curl -O https://dl.google.com/go/go1.13.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz
RUN export PATH=$PATH:/usr/local/go/bin
RUN /usr/local/go/bin/go get -v github.com/quasilyte/phpgrep/cmd/phpgrep

RUN apt-get update \
    && apt-get install -y ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Configure mysql sock
RUN ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock

# Install wp-cli
RUN curl --insecure -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Setup database `test`
RUN service mysql start \
    && mysql --user="root" --execute="CREATE DATABASE test;"

RUN service mysql start \
    && wp core download --path=/var/www/html --allow-root \
    && wp core config --path=/var/www/html --dbname=test --dbuser=root --allow-root \
    && wp core install --url=http://localhost --title=Test --admin_user=admin --admin_password=12345 --admin_email=test@test.com --path=/var/www/html --allow-root --skip-email

# Start the mysql
ENTRYPOINT service mysql start && bash
