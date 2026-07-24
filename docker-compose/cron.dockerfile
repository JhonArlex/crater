FROM composer:latest AS composer-stage

FROM php:8.1-fpm-alpine

RUN apk add --no-cache \
    php8-bcmath

RUN docker-php-ext-install pdo pdo_mysql bcmath

# Copy composer from the official image
COPY --from=composer-stage /usr/bin/composer /usr/bin/composer

# Working directory
WORKDIR /var/www

# Copy application code (build context is the repo root)
COPY . /var/www/

# Install composer dependencies
RUN composer install --no-dev --no-interaction --optimize-autoloader

# Copy crontab
COPY docker-compose/crontab /etc/crontabs/root

CMD ["crond", "-f"]
