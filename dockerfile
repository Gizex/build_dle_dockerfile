FROM php:7.4-fpm

ARG USER_ID=1000
ARG GROUP_ID=1000

WORKDIR /tmp

COPY dle.zip ./

ENV DLE_VERSION 14.3

RUN apt-get update && apt-get install -y \
 libfreetype6-dev \
 libjpeg62-turbo-dev \
 libpng-dev \
 libzip-dev \
 zip \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd \
 && docker-php-ext-install mysqli \
 && docker-php-ext-install zip

# RUN set -ex; \
#     apt-get update; \
#     apt-get install -y --no-install-recommends libonig-dev libzip-dev unzip zlib1g-dev libxslt-dev curl libonig-dev libxml2-dev libpng-dev libcurl4 libcurl4-openssl-dev; \
#     docker-php-ext-install mysqli mbstring xsl  gd pdo_mysql curl xml zip sockets bcmath;

RUN usermod -u ${USER_ID} www-data; \
    groupmod -g ${GROUP_ID} www-data; 
    

VOLUME /var/www/html
ADD composer.json /var/www/html


COPY docker-entrypoint.sh ./

RUN chmod +x ./docker-entrypoint.sh


ENTRYPOINT ["./docker-entrypoint.sh"]
RUN  cd /var/www/html \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
    && php composer.phar install
# RUN chmod 777 /var/www/html/{templates,engine/{data,cache}}; \
#     chmod -R 777 /var/www/html/{backup,uploads}
EXPOSE 9000    
CMD ["php-fpm /var/www/html/install.php"]