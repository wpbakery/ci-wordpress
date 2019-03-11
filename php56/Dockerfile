FROM ubuntu:18.04

ENV WP_TESTS_DIR /opt/wp-tests
ENV WP_TESTS_ABSPATH /var/www/html/
ENV WP_TESTS_DOMAIN localhost

COPY wp-tests.tar.gz /opt

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y curl git zip \
    && apt-get install -y software-properties-common \
    && apt-get install -y ca-certificates \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update

RUN apt-get install -y mysql-server libmysqlclient-dev --no-install-recommends

RUN apt-get install -y php7.1 php7.1-common php7.1-dev php7.1-dom php7.1-xdebug php7.1-zip php7.1-cli php7.1-fpm php7.1-curl php7.1-mcrypt php7.1-mysql php7.1-gd php7.1-readline
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# POST and max upload sizes on php.ini
RUN sed -i "/upload_max_filesize = .*/c\upload_max_filesize = 200M" /etc/php/7.1/cli/php.ini \
    && sed -i "/post_max_size = .*/c\post_max_size = 200M" /etc/php/7.1/cli/php.ini \
    && sed -i "/memory_limit = .*/c\memory_limit = 256M" /etc/php/7.1/cli/php.ini \
    && sed -i "s/zend_extension/;zend_extension/g" /etc/php/7.1/mods-available/xdebug.ini

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
