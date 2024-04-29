FROM circleci/php:7.4.2-apache

COPY wp-tests-9.0.0.tar.gz /opt

# Install packages
RUN \
  sudo apt-get update || sudo apt-get update && \
  sudo apt-get install -y apt-transport-https lsb-release && \
  sudo apt-get install -y libzip-dev && \
  sudo apt-get install -y zlib1g-dev libicu-dev g++ libpng-dev

# Install packages for php and mysql
RUN \
  sudo apt-get update && \
  sudo docker-php-ext-install zip && \
  sudo docker-php-ext-configure intl && \
  sudo docker-php-ext-install intl && \
  sudo docker-php-ext-install pdo pdo_mysql mysqli && \
  sudo docker-php-ext-install gd && \
  sudo apt-get -y install default-mysql-client
# Install tools for Wordpress

RUN \
  sudo tar -zxvf /opt/wp-tests-9.0.0.tar.gz -C /opt && sudo chown root:root /opt/wp-tests -R && \
  curl --insecure -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
  chmod +x wp-cli.phar && \
  sudo mv wp-cli.phar /usr/local/bin/wp

# Define default command.
CMD ["bash"]
