FROM debian:buster-slim

# set version label
LABEL maintainer="bigrob8181"

ARG PUID=1000
ARG PGID=1000

RUN \
    echo "**** Add User and Group ****" && \
    addgroup --gid ${PGID} abc && \
    adduser --system --no-create-home --uid ${PUID} --gid ${PGID} --disabled-password abc


RUN \
 echo "**** install Base dependencies ****" && \
 apt update && \
 apt install -y \
    bash \
    libapache2-mod-php7.3 \
    git \
    php7.3-mysql \
    php7.3-imagick \
    php7.3-mbstring \
    php7.3-json \
    php7.3-gd \
    php7.3-xml \
    php7.3-zip \
    #mariadb-server \
    composer \
    && rm -rf /var/lib/apt/lists/*


RUN \
    echo "**** Clone the repo ****" && \
    cd /var/www/html && \
    git clone --recurse-submodules https://github.com/LycheeOrg/Lychee-Laravel.git


RUN \
    echo "**** install php libraries ****" && \
    cd /var/www/html/Lychee-Laravel && \
    composer install --no-dev && \
    chown -R www-data:www-data \
    	/var/www/html/Lychee-Laravel


RUN \
    echo "**** Laravel requires mode rewrite to be enabled ****" && \
    a2enmod rewrite


RUN \
    echo "**** Add custom Site to apache and enable it ****"
COPY default.conf /etc/apache2/sites-available/default.conf
RUN \
    ls -la /etc/apache2/sites-available/ && \
    a2ensite default.conf && \
    a2dissite 000-default.conf
COPY apache2.conf /etc/apache2/apache2.conf


EXPOSE 80
VOLUME /conf /uploads

WORKDIR /var/www/html/Lychee-Laravel

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "apache2ctl", "-D", "FOREGROUND" ]
