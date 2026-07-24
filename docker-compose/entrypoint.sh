#!/bin/sh

# Minimal entrypoint - just fix permissions and start PHP-FPM

# Ensure storage directories exist
mkdir -p /var/www/storage/framework/cache/data
mkdir -p /var/www/storage/framework/sessions
mkdir -p /var/www/storage/framework/views
mkdir -p /var/www/storage/logs

# Touch .env so it exists (Crater installer will populate it)
touch /var/www/.env

# Fix all permissions for PHP-FPM (runs as www-data)
chown -R www-data:www-data /var/www/.env /var/www/storage /var/www/bootstrap/cache
chmod -R 775 /var/www/storage /var/www/bootstrap/cache
chmod 664 /var/www/.env

# Start PHP-FPM (as root - forks workers as www-data)
exec php-fpm
