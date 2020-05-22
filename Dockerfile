FROM php:7.4-apache
MAINTAINER Nexus Netsoft

RUN a2enmod rewrite vhost_alias
RUN echo 'memory_limit = 1024M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

RUN apt-get update \
 && apt-get install -y git vim curl wget unzip zip sudo default-mysql-client gnupg gettext cron libzip-dev\
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

# Install VueJs Componente
RUN curl -sL https://deb.nodesource.com/setup_13.x -o nodesource_setup.sh && bash nodesource_setup.sh && apt-get -y --force-yes install nodejs
RUN npm install
RUN rm -rf nodesource_setup.sh
RUN npm install vue babel lint @vue/cli
RUN npm install @vue/cli-service
RUN npm install @vue/cli-service-global
RUN npm install @vue/cli-plugin-babel
RUN npm install @vue/cli-plugin-eslint
RUN npm install vue-template-compiler
RUN npm install axios
RUN npm install vue-notifications
RUN npm install mini-toastr
RUN npm install lodash
RUN npm install acorn-jsx
RUN npm install esquery
RUN cp -Rf /var/www/html/node_modules /root/ /var/www/

RUN usermod -g www-data root