FROM alpine:3.4
LABEL maintainer="Coffee Z <chinaphp.com@gmail.com>"

RUN apk update && apk upgrade

#时区配置
ENV TIMEZONE Asia/Shanghai
RUN apk add tzdata
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
RUN echo $TIMEZONE > /etc/timezone

RUN apk --update add --no-cache --update \
    bash \
	nginx \
	curl \
	php5-cli \
	php5-common \
	php5-fpm \
	php5-phar \
	php5-pdo \
	php5-json \
	php5-openssl \
	php5-mysql \
	php5-mysqli \
	php5-pdo_mysql \
	php5-mcrypt \
	php5-opcache \
	php5-sqlite3 \
	php5-pdo_sqlite \
	php5-ctype \
	php5-intl \
	php5-zlib \
	php5-curl \
	php5-gd \
	php5-xml \
	php5-dom \
	php5-memcache \
  	supervisor \
    xvfb \
    ttf-freefont \
    fontconfig \
    dbus; 
#     qt5-qtbase-dev; \
#     apk add --no-cache \
#             --update \
#             --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
#             --allow-untrusted \
#     wkhtmltopdf;
    
       

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    chmod +x /usr/local/bin/composer;


# 软件包参数配置
ENV PHP_MEMORY_LIMIT 512M
ENV MAX_UPLOAD 50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV MAX_EXECUTION_TIME 600
ENV PHP_MAX_POST 100M

RUN touch /etc/php5/fpm.d/none.conf
RUN chmod 777 -R /var/log/



RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/php-fpm.conf && \
sed -i -e "s/listen\s*=\s*127.0.0.1:9000/listen = 9000/g" /etc/php5/php-fpm.conf && \
sed -i "s|date.timezone =.*|date.timezone = ${TIMEZONE}|" /etc/php5/php.ini && \
sed -i "s|memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|" /etc/php5/php.ini && \
sed -i "s|upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|" /etc/php5/php.ini && \
sed -i "s|max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|" /etc/php5/php.ini && \
sed -i "s|max_execution_time =.*|max_execution_time = ${MAX_EXECUTION_TIME}|" /etc/php5/php.ini && \
sed -i "s|post_max_size =.*|max_file_uploads = ${PHP_MAX_POST}|" /etc/php5/php.ini && \
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/php.ini && \
sed -i "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/" /etc/php5/php.ini && \
sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/php.ini && \
sed -i "s/;catch_workers_output = yes/catch_workers_output = yes/" /etc/php5/php-fpm.conf && \
sed -i "s/;error_log = php_errors.log/error_log = \/apps\/logs\/php_errors.log/" /etc/php5/php.ini && \
mkdir /apps && \
mkdir /run/nginx

WORKDIR /apps

VOLUME /var/www/html


RUN rm /etc/nginx/nginx.conf

ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/default.conf /etc/nginx/default.d/default.conf

ADD conf/nginx-supervisor.ini /etc/supervisor/conf.d/nginx-supervisor.ini

RUN rm -rf /var/cache/apk/*


COPY conf/zzz-custom.ini /etc/php5/conf.d/
EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/nginx-supervisor.ini"]
