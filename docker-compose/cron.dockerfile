FROM composer:latest AS composer-stage

FROM php:8.1-fpm-alpine

# Install system dependencies for PHP extensions
RUN apk add --no-cache \
    libpng-dev \
    libzip-dev \
    libxml2-dev \
    libmagickwand-dev \
    imagemagick-dev \
    mariadb-client

# Install PHP extensions (must match the main Dockerfile's extensions)
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

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
