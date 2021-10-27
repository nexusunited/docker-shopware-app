FROM php:7.4-apache
MAINTAINER Nexus Netsoft

RUN a2enmod rewrite vhost_alias
RUN echo 'memory_limit = 1024M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

RUN apt-get update \
 && apt-get install -y git vim curl wget python3 unzip zip sudo default-mysql-client gnupg gettext cron libzip-dev\
                        libfreetype6-dev libmcrypt-dev libgmp-dev libbz2-dev libpng-dev libjpeg62-turbo-dev libicu-dev libyaml-dev\
 && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install -j$(nproc) iconv pdo mysqli pdo_mysql intl bcmath gmp bz2 zip \
 && apt-get clean

RUN docker-php-ext-configure gd && docker-php-ext-install -j$(nproc) gd
RUN pecl install -o -f redis \
 && pecl install -o -f xdebug \
 && docker-php-ext-enable redis \
 && docker-php-ext-enable xdebug \
 && echo "" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.default_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.profiler_enable=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.inactive


# Composer Phar
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php \
  && php -r "unlink('composer-setup.php');" \
  && mv composer.phar /usr/local/bin/composer \
  && chmod +x /usr/local/bin/composer \
  && /usr/local/bin/composer global require hirak/prestissimo



ENV NVM_DIR /usr/local/nvm
ENV NVM_VERSION v0.35.3
ENV NODE_VERSION 10.22.0

# NVM & NPM
RUN curl https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | bash \
 && . $NVM_DIR/nvm.sh \
 && bash -i -c 'nvm ls-remote' \
 && bash -i -c 'nvm install $NODE_VERSION'

RUN ln -s $NVM_DIR/versions/node/v$NODE_VERSION/bin/node /usr/local/bin/node \
 && ln -s $NVM_DIR/versions/node/v$NODE_VERSION/bin/npm /usr/local/bin/npm

RUN usermod -g www-data root

WORKDIR /data/shop/development

