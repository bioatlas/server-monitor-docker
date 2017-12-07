FROM php:7.1-apache

WORKDIR /var/www/html/

RUN apt-get update && apt-get -y install \
	git unzip zlib1g-dev nano cron supervisor && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

RUN /usr/sbin/a2dismod 'mpm_*' && /usr/sbin/a2enmod mpm_prefork

RUN docker-php-ext-install zip && \
	docker-php-ext-install mysqli && \
	docker-php-ext-install pdo_mysql

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

#RUN composer create-project spatie/server-monitor-app

ENV VERSION 3.2.0
ENV PHPMONITOR_URL https://github.com/phpservermon/phpservermon/releases/download/v$VERSION/phpservermon-$VERSION.tar.gz

RUN set -x \
	&& cd /var/www/html \
	&& rm -rf * \
	&& cd /tmp \
	&& curl -L -o download $PHPMONITOR_URL \ 
	&& mv download phpmonitor.tar.gz \
	&& tar -xvf phpmonitor.tar.gz --strip-components=1 \
	&& cd phpservermon-$VERSION \
	&& mv * /var/www/html \ 
	&& cd /var/www/html \
	&& touch config.php \
	&& chmod 0777 config.php

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

COPY config.php /var/www/html/config.php

# to schedule the crontab command we use "supervisord.conf"
# therefore we need first to clean out the earlier entrypoint
ENTRYPOINT []

RUN mkdir -p /var/run/cron /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN echo '* * * * * bash -c "/usr/local/bin/php /var/www/html/cron/status.cron.php  >> /var/log/cron.log 2>&1"'  > /etc/crontab
RUN chmod 644 /etc/crontab
RUN crontab /etc/crontab
RUN touch /var/log/cron.log
RUN touch /tmp/crontab
RUN chmod 644 /tmp/crontab

CMD exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

