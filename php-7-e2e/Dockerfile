FROM wpbakery/ci-wordpress:php7

USER root

COPY cypress.env.json /var/www/html

# Update ap-get and install nodejs
RUN \
  apt-get update && \
  curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  apt-get install -y nodejs && \
  curl -s https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list

RUN apt-get update \
    && apt-get install -y supervisor git

ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Install Chrome

RUN \
  apt-get update && \
  apt-get install -y dbus-x11 google-chrome-stable && \
  rm -rf /var/lib/apt/lists/*

RUN \
  npm i -g yarn

# Test setup
RUN node -v
RUN npm -v
RUN yarn -v
RUN google-chrome --version
RUN git --version
RUN php -v

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]