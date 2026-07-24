#!/bin/sh

# Laravel startup script (runs as root, php-fpm forks workers as www-data)

# Ensure storage directories exist
mkdir -p /var/www/storage/framework/cache/data
mkdir -p /var/www/storage/framework/sessions
mkdir -p /var/www/storage/framework/views
mkdir -p /var/www/storage/logs

# Generate app key if not set
su -s /bin/sh crater-user -c 'cd /var/www && php artisan key:generate --force' 2>/dev/null || true

# Run package discovery
su -s /bin/sh crater-user -c 'cd /var/www && php artisan package:discover --ansi' 2>/dev/null || true

# Run config/route/view cache
su -s /bin/sh crater-user -c 'cd /var/www && php artisan config:cache' 2>/dev/null || true
su -s /bin/sh crater-user -c 'cd /var/www && php artisan route:cache' 2>/dev/null || true
su -s /bin/sh crater-user -c 'cd /var/www && php artisan view:cache' 2>/dev/null || true

# Run migrations (safe - won't re-run already-applied migrations)
su -s /bin/sh crater-user -c 'cd /var/www && php artisan migrate --force' 2>/dev/null || true

# Fix permissions for PHP-FPM (runs as www-data)
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache 2>/dev/null || true
chmod -R 775 /var/www/storage /var/www/bootstrap/cache 2>/dev/null || true

# Start PHP-FPM (as root - forks workers as www-data per the pool config)
exec php-fpm
