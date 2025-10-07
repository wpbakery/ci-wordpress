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

COPY wp-tests-9.0.0.tar.gz /opt

ENV DEBIAN_FRONTEND=noninteractive

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

RUN apt-get install -y php7.4 php7.4-common php7.4-dev php7.4-dom php7.4-xdebug php7.4-zip php7.4-cli php7.4-mbstring php7.4-pdo php7.4-fpm php7.4-curl php7.4-mysql php7.4-gd php7.4-readline php7.4-xdebug
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable Xdebug for code coverage
RUN echo "zend_extension=xdebug.so" >> /etc/php/7.4/cli/php.ini \
    && echo "xdebug.mode=coverage" >> /etc/php/7.4/cli/php.ini

# POST and max upload sizes on php.ini
RUN sed -i "/upload_max_filesize = .*/c\upload_max_filesize = 200M" /etc/php/7.4/cli/php.ini \
    && sed -i "/post_max_size = .*/c\post_max_size = 200M" /etc/php/7.4/cli/php.ini \
    && sed -i "/memory_limit = .*/c\memory_limit = 256M" /etc/php/7.4/cli/php.ini \
    && sed -i "s/zend_extension/;zend_extension/g" /etc/php/7.4/mods-available/xdebug.ini

RUN tar -zxvf /opt/wp-tests-9.0.0.tar.gz -C /opt && chown root:root /opt/wp-tests -R

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