FROM ubuntu:22.04

ENV WP_TESTS_DIR /opt/wp-tests
ENV WP_TESTS_ABSPATH /var/www/html/
ENV WP_TESTS_DOMAIN localhost

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y curl git zip \
    && apt-get install -y software-properties-common \
    && apt-get install -y ca-certificates \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update

# Add Node.js repository and install specific version
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

# Install npm with Node.js
RUN npm install -g npm@7

RUN apt-get install -y mysql-server libmysqlclient-dev --no-install-recommends

RUN apt-get install -y php8.1 php8.1-common php8.1-dev php8.1-dom php8.1-xdebug php8.1-zip php8.1-cli php8.1-mbstring php8.1-pdo php8.1-fpm php8.1-curl php8.1-mysql php8.1-gd php8.1-readline
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# POST and max upload sizes on php.ini
RUN sed -i "/upload_max_filesize = .*/c\upload_max_filesize = 200M" /etc/php/8.1/cli/php.ini \
    && sed -i "/post_max_size = .*/c\post_max_size = 200M" /etc/php/8.1/cli/php.ini \
    && sed -i "/memory_limit = .*/c\memory_limit = 256M" /etc/php/8.1/cli/php.ini \
    && sed -i "s/zend_extension/;zend_extension/g" /etc/php/8.1/mods-available/xdebug.ini

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
