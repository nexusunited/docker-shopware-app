FROM php:7.0-apache-stretch
MAINTAINER Mike Bertram <bertram@nexus-netsoft.com>

RUN a2enmod rewrite vhost_alias

RUN apt-get update \
 && apt-get install -y vim curl wget unzip sudo \
                        libfreetype6-dev libmcrypt-dev libgmp-dev libbz2-dev libpng-dev libjpeg62-turbo-dev libxml2-dev libicu-dev \
                        mysql-client zsh\
 && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install -j$(nproc) iconv pdo mysqli pdo_mysql intl bcmath gmp bz2 zip soap mcrypt \
 && apt-get clean

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install -j$(nproc) gd

ADD https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz /tmp/

RUN tar xzfC /tmp/ioncube_loaders_lin_x86-64.tar.gz /tmp/ \
 && rm /tmp/ioncube_loaders_lin_x86-64.tar.gz \
 && cp /tmp/ioncube/ioncube_loader_lin_7.0.so /usr/local/lib/php/extensions/* \
 && rm -rf /tmp/ioncub*

RUN pecl install -o -f redis \
 && pecl install -o -f xdebug \
 && docker-php-ext-enable redis \
 && docker-php-ext-enable xdebug \
 && echo "" >> /usr/local/etc/php/conf.d/docker-php-ext-ioncube.ini \
 && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/ioncube_loader_lin_7.0.so" \
 >> /usr/local/etc/php/conf.d/docker-php-ext-ioncube.ini \
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

RUN echo "memory_limit = 850M" >> /usr/local/etc/php/conf.d/docker-shopware-ext.ini

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php \
  && php -r "unlink('composer-setup.php');" \
  && mv composer.phar /usr/local/bin/composer \
  && chmod +x /usr/local/bin/composer \
  && /usr/local/bin/composer global require hirak/prestissimo

# Install best shell and oh-my-zsh, but dont enable it on default. Otherwise Windows user look like this: 😭
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

RUN usermod -g www-data root

WORKDIR /data/shop/development

VOLUME ["/usr/local/etc/php/conf.d"]