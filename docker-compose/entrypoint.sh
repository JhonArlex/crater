#!/bin/sh

# Minimal entrypoint - fix permissions, create storage link, start PHP-FPM

# Ensure storage directories exist
mkdir -p /var/www/storage/framework/cache/data
mkdir -p /var/www/storage/framework/sessions
mkdir -p /var/www/storage/framework/views
mkdir -p /var/www/storage/logs

# Create .env placeholder so Crater installer can write to it
touch /var/www/.env

# Create storage symlink (needs write to public/ - Crater installer calls this)
# Run as crater-user since files are owned by crater-user before chown
su -s /bin/sh crater-user -c 'cd /var/www && php artisan storage:link' 2>/dev/null || true
# Also ensure public/storage is a valid symlink
ln -sf /var/www/storage/app/public /var/www/public/storage 2>/dev/null || true

# Fix all permissions for PHP-FPM (runs as www-data)
chown -R www-data:www-data /var/www/.env /var/www/storage /var/www/bootstrap/cache /var/www/public
chmod -R 775 /var/www/storage /var/www/bootstrap/cache /var/www/public
chmod 664 /var/www/.env

# Start PHP-FPM (as root - forks workers as www-data)
exec php-fpm
