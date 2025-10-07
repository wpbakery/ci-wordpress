
FROM ubuntu:22.04

ENV MYSQL_HOST 127.0.0.1
ENV MYSQL_DB mate
ENV MYSQL_USER root
ENV MYSQL_ALLOW_EMPTY_PASSWORD true
ENV WP_TESTS_DIR /opt/wp-tests
ENV WP_TESTS_DOMAIN localhost
ENV WP_TESTS_ABSPATH /var/www/html/
ENV WP_TESTS_DB_NAME test
ENV WP_TESTS_DB_USER wpuser
ENV WP_TESTS_DB_HOST 127.0.0.1
ENV DEBIAN_FRONTEND=noninteractive
ENV PHP_VERSIONS="7.4 8.0 8.1 8.2 8.3 8.4"
ENV PHP_MODULES="cli common dev dom xdebug zip mbstring pdo fpm curl mysql gd readline xml intl soap bcmath opcache"

COPY wp-tests.tar.gz /opt

RUN apt-get update \
    && apt-get install -y curl git zip \
    && apt-get install -y software-properties-common \
    && apt-get install -y ca-certificates \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update

# Add Node.js repository and install specific version
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install npm with Node.js
RUN npm install -g npm@7

RUN apt-get install -y mysql-server libmysqlclient-dev --no-install-recommends

RUN for v in $PHP_VERSIONS; do \
    apt-get install -y $(echo $PHP_MODULES | sed "s/[^ ]*/php$v-&/g"); \
done

# Register all PHP versions with update-alternatives
RUN for v in $PHP_VERSIONS; do \
    shortv=$(echo $v | tr -d .); \
    # Register alternatives
    update-alternatives --install /usr/bin/php php /usr/bin/php$v $shortv || true; \
    update-alternatives --install /usr/bin/php-config php-config /usr/bin/php-config$v $shortv || true; \
    update-alternatives --install /usr/bin/phpize phpize /usr/bin/phpize$v $shortv || true; \
done

# Set default PHP version (can be overridden in workflow)
RUN update-alternatives --set php /usr/bin/php7.4 && \
    update-alternatives --set php-config /usr/bin/php-config7.4 && \
    update-alternatives --set phpize /usr/bin/phpize7.4


RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN for v in $PHP_VERSIONS; do \
    echo "zend_extension=xdebug.so" >> /etc/php/$v/cli/php.ini && \
    echo "xdebug.mode=coverage" >> /etc/php/$v/cli/php.ini && \
    sed -i "s/zend_extension/;zend_extension/g" /etc/php/$v/mods-available/xdebug.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 200M/" /etc/php/$v/cli/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 200M/" /etc/php/$v/cli/php.ini && \
    sed -i "s/memory_limit = .*/memory_limit = 256M/" /etc/php/$v/cli/php.ini; \
done

RUN tar -zxvf /opt/wp-tests.tar.gz -C /opt && chown root:root /opt/wp-tests -R

WORKDIR /var/www/html

# Configure mysql sock
RUN ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock

# Install wp-cli
RUN curl --insecure -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Setup database `test`
RUN usermod -d /var/lib/mysql mysql && find /var/lib/mysql -exec touch {} \; && /etc/init.d/mysql start \
    && mysql --user="root" --execute="CREATE DATABASE test;" \
    && mysql --user="root" --execute="CREATE USER 'wpuser'@'127.0.0.1'; GRANT ALL PRIVILEGES ON test.* TO 'wpuser'@'127.0.0.1';"

RUN find /var/lib/mysql -exec touch {} \; && /etc/init.d/mysql start \
    && wp core download --path=/var/www/html --allow-root \
    && wp core config --path=/var/www/html --dbhost=127.0.0.1 --dbname=test --dbuser=wpuser --allow-root \
    && wp core install --url=http://localhost --title=Test --admin_user=admin --admin_password=12345 --admin_email=test@test.com --path=/var/www/html --allow-root

# Start the mysql
ENTRYPOINT /etc/init.d/mysql start && bash