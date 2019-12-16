FROM ubuntu:18.04

ENV WP_TESTS_DIR /opt/wp-tests
ENV WP_TESTS_ABSPATH /var/www/html/
ENV WP_TESTS_DOMAIN localhost
ENV WP_TESTS_DB_USER wpuser
ENV WP_TESTS_DB_HOST 127.0.0.1
ENV WP_TESTS_DB_PASS wpuser
ENV WP_TESTS_DB_NAME test

COPY wp-tests-8.0.1.tar.gz /opt

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y curl wget git zip \
    && apt-get install -y apt-transport-https software-properties-common \
    && apt-get install -y zlib1g-dev libicu-dev g++ libpng-dev ca-certificates \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update

RUN  apt-get update && apt-get install -y mysql-server libmysqlclient-dev --no-install-recommends

RUN apt-get install -y php7.3 php7.3-common php7.3-dev php7.3-dom php7.3-xdebug php7.3-zip php7.3-cli php7.3-mbstring php7.3-pdo php7.3-fpm php7.3-curl php7.3-mysql php7.3-gd php7.3-readline

# POST and max upload sizes on php.ini
RUN sed -i "/upload_max_filesize = .*/c\upload_max_filesize = 200M" /etc/php/7.3/cli/php.ini \
    && sed -i "/post_max_size = .*/c\post_max_size = 200M" /etc/php/7.3/cli/php.ini \
    && sed -i "/memory_limit = .*/c\memory_limit = 256M" /etc/php/7.3/cli/php.ini \
    && sed -i "s/zend_extension/;zend_extension/g" /etc/php/7.3/mods-available/xdebug.ini

RUN tar -zxvf /opt/wp-tests-8.0.1.tar.gz -C /opt

# Install GO (required for phpgrep)
RUN curl -O https://dl.google.com/go/go1.13.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz
RUN export PATH=$PATH:/usr/local/go/bin
RUN /usr/local/go/bin/go get -v github.com/quasilyte/phpgrep/cmd/phpgrep

RUN chown root:root /opt/wp-tests -R

WORKDIR /var/www/html

# Configure mysql sock
RUN ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock

# Install wp-cli
RUN curl --insecure -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
  chmod +x wp-cli.phar && \
  mv wp-cli.phar /usr/local/bin/wp

# Setup database `test`
RUN usermod -d /var/lib/mysql mysql && find /var/lib/mysql -exec touch {} \; && /etc/init.d/mysql start \
    && mysql --user="root" --execute="CREATE DATABASE test;" \
    && mysql --user="root" --execute="CREATE USER 'wpuser'@'127.0.0.1' IDENTIFIED BY 'wpuser'; GRANT ALL PRIVILEGES ON test.* TO 'wpuser'@'127.0.0.1';"

# Install WP
RUN find /var/lib/mysql -exec touch {} \; && /etc/init.d/mysql start \
    && wp core download --path=/var/www/html --allow-root \
    && wp core config --path=/var/www/html --dbhost=127.0.0.1 --dbname=test --dbuser=wpuser --dbpass=wpuser --allow-root \
    && wp core install --url=http://localhost --title=Test --admin_user=admin --admin_password=12345 --admin_email=test@test.com --path=/var/www/html --allow-root --skip-email

# Install node and chrome
RUN \
  curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g yarn
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list && \
  apt-get update && \
  apt-get install -y dbus-x11 google-chrome-stable

# Install required libs for cypress
RUN \
  rm -rf /var/lib/apt/lists/* && \
  apt-get update && apt-get install -y libgtk2.0-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 xvfb && \
  export DBUS_SESSION_BUS_ADDRESS=/dev/null && \
  export TERM=xterm && \
  export npm_config_loglevel=warn && \
  export npm_config_unsafe_perm=true

# Start the mysql
ENTRYPOINT find /var/lib/mysql -type f -exec touch {} \; && service mysql start && bash
