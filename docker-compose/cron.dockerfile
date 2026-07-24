FROM php:8.1-fpm-alpine

RUN apk add --no-cache \
    php8-bcmath

RUN docker-php-ext-install pdo pdo_mysql bcmath

COPY docker-compose/crontab /etc/crontabs/root

# Copy application code (dependencies already installed in base image)
COPY --from=crater-php /var/www /var/www
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www

CMD ["crond", "-f"]
