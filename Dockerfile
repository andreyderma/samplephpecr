# Use Alpine Linux
FROM alpine:3.3

# Declare maintainer
MAINTAINER Andrey Derma <andrey.derma@mekar.id>

# Timezone
ENV TIMEZONE Asia/Jakarta
ENV PHP_MEMORY_LIMIT 512M
ENV MAX_UPLOAD 50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST 100M

# Let's roll
RUN	apk update && \
	apk upgrade && \
	apk add --update tzdata && \
	cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
	echo "${TIMEZONE}" > /etc/timezone && \
	apk add --update \
		php-mcrypt \
		php-soap \
		php-openssl \
		php-gmp \
		php-pdo_odbc \
		php-json \
		php-dom \
		php-pdo \
		php-zip \
		php-mysql \
		php-apcu \
		php-bcmath \
		php-gd \
		php-xcache \
		php-odbc \
		php-pdo_mysql \
		php-gettext \
		php-xmlreader \
		php-xmlrpc \
		php-bz2 \
		php-memcache \
		php-iconv \
		php-pdo_dblib \
		php-curl \
		git \
		php-ctype \
		php-fpm && \
	sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/php-fpm.conf && \
	sed -i -e "s/listen\s*=\s*127.0.0.1:9000/listen = 9000/g" /etc/php/php-fpm.conf && \
	sed -i -e "s/error_log\s*=\s*\/var\/log\/php-fpm.log/error_log = \/proc\/self\/fd\/2/" /etc/php/php-fpm.conf && \
	sed -i "s|;date.timezone =.*|date.timezone = ${TIMEZONE}|" /etc/php/php.ini && \
	sed -i "s|memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|" /etc/php/php.ini && \
    sed -i "s|upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|" /etc/php/php.ini && \
    sed -i "s|max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|" /etc/php/php.ini && \
    sed -i "s|post_max_size =.*|post_max_size = ${PHP_MAX_POST}|" /etc/php/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/php.ini && \
	mkdir /www && \
	apk del tzdata && \
	rm -rf /var/cache/apk/*

# Install nginx
RUN apk add --update nginx && \
    rm -rf /var/cache/apk/* && \
    chown -R nginx:www-data /var/lib/nginx

# Nginx configuration
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Set Workdir
WORKDIR /usr/share/nginx/html

ADD ./ .

RUN mkdir -p /usr/share/nginx/html/log 
RUN chown -R nobody /usr/share/nginx/html/log && \
	rm -rf /usr/share/nginx/html/index.html

# Expose volumes
VOLUME ["/usr/share/nginx/html"]

# Expose ports
EXPOSE 80

COPY ./docker/api_entrypoint.sh /entrypoint.sh

#RUN chmod +x /entrypoint.sh

#ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/php-fpm"]