FROM php:7.0-apache

ENV WP_TESTS_DIR /opt/wp-tests
ENV WP_TESTS_ABSPATH /var/www/html/
ENV WP_TESTS_DOMAIN localhost

COPY wp-tests.tar.gz $WP_TESTS_DIR

# Install dotdeb repo, PHP, composer and selected extensions
RUN apt-get update \
    && apt-get install -y curl \
    && echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list \
    && curl -sS https://www.dotdeb.org/dotdeb.gpg | apt-key add - \
    && apt-get update \
    && apt-get -y --no-install-recommends install php7.0-cli php7.0-fpm php7.0-apcu php7.0-apcu-bc php7.0-curl php7.0-json php7.0-mcrypt php7.0-opcache php7.0-readline \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && cp /etc/php/7.0/fpm/php.ini $PHP_INI_DIR \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && pecl install -o -f xdebug \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini

# POST and max upload sizes on php.ini
RUN sed -i "/upload_max_filesize = .*/c\upload_max_filesize = 200M" $PHP_INI_DIR/php.ini \
    && sed -i "/post_max_size = .*/c\post_max_size = 200M" $PHP_INI_DIR/php.ini \
    && sed -i "/memory_limit = .*/c\memory_limit = 256M" $PHP_INI_DIR/php.ini
# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install php7.0-mysql \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN tar -zxcf /opt/wp-tests.tar.gz -C /opt

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y mysql-server libmysqlclient-dev --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Install PhpUnit
RUN curl -SL --insecure "https://phar.phpunit.de/phpunit.phar" -o phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/bin/phpunit

# Install git, ssh, wget, svn??
#RUN apt-get update \
 #   && apt-get install -y subversion git ssh wget --no-install-recommends \
 #   && rm -rf /var/lib/apt/lists/*

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
    && wp core install --url=http://localhost --title=Test --admin_user=admin --admin_password=12345 --admin_email=test@test.com --path=/var/www/html --allow-root

# Start the mysql
ENTRYPOINT service mysql start && bash
