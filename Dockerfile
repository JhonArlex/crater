FROM php:8.1-fpm as base

# Arguments defined in docker-compose.yml
ARG user=crater-user
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libmagickwand-dev \
    mariadb-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

# Copy application code (production-ready: code is baked into the image)
COPY --chown=$user:$user . /var/www/

# Install composer dependencies (skip scripts - no .env at build time)
RUN composer install --no-dev --no-interaction --optimize-autoloader --no-scripts

# Copy entrypoint script
COPY docker-compose/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

# ============================================================
# Nginx stage: build a self-contained nginx image with static assets
# ============================================================
FROM nginx:1.17-alpine as nginx

COPY ./docker-compose/nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=base /var/www/public /var/www/public
