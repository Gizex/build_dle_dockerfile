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
    libonig-dev unzip zlib1g-dev libxslt-dev curl libxml2-dev  libcurl4 libcurl4-openssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip mbstring xsl pdo_mysql curl xml zip sockets bcmath

# RUN set -ex; \
#     apt-get update; \
#     apt-get install -y --no-install-recommends libonig-dev libzip-dev unzip zlib1g-dev libxslt-dev curl libonig-dev libxml2-dev libpng-dev libcurl4 libcurl4-openssl-dev; \
#     docker-php-ext-install mysqli mbstring xsl  gd pdo_mysql curl xml zip sockets bcmath;

RUN usermod -u ${USER_ID} www-data; \
    groupmod -g ${GROUP_ID} www-data; 
    


ADD composer.json .


COPY docker-entrypoint.sh ./

RUN chmod +x ./docker-entrypoint.sh


ENTRYPOINT ["./docker-entrypoint.sh"]
EXPOSE 9000    
CMD ["php-fpm"]