FROM php:7.4.11-fpm-alpine

LABEL MAINTAINER="Vincent Nguyen <mr.vannguyen92@gmail.com>"

COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install PHP modules - TODO check in other frameworks
RUN docker-php-ext-install bcmath pdo_mysql

# Install Postgresql
# RUN apk --no-cache add postgresql-dev
# RUN docker-php-ext-install pgsql pdo_pgsql

RUN apk add --update apache2 apache2-proxy \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log

# Setting Apache2
RUN sed -i 's/User\ apache/User\ www-data/' /etc/apache2/httpd.conf \
    && sed -i 's/Group\ apache/Group\ www-data/' /etc/apache2/httpd.conf \
    && sed -i 's/#ServerAdmin\ you@example.com/ServerAdmin\ you@example.com/' /etc/apache2/httpd.conf \
    && sed -i 's/#ServerName\ www.example.com:80/ServerName\ www.example.com:80/' /etc/apache2/httpd.conf \
    && sed -i 's#^DocumentRoot ".*#DocumentRoot "/var/www/html"#g' /etc/apache2/httpd.conf \
    && sed -i 's#Directory "/var/www/localhost/htdocs"#Directory "/var/www/html"#g' /etc/apache2/httpd.conf \
    && sed -i 's#AllowOverride None#AllowOverride All#' /etc/apache2/httpd.conf \
    && sed -i 's#DirectoryIndex index\.html#DirectoryIndex index\.html index\.php#' /etc/apache2/httpd.conf \
    && echo 'ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000/var/www/html/$1' >> /etc/apache2/httpd.conf \
    && echo "<?php phpinfo();" > /var/www/html/index.php \
    # Enable commonly used apache modules
    && sed -i 's/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule\ deflate_module/LoadModule\ deflate_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule\ expires_module/LoadModule\ expires_module/' /etc/apache2/httpd.conf
    # Modify php.ini settings
    # && sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php7/php.ini

COPY entrypoint /usr/local/bin/
CMD ["entrypoint"]
