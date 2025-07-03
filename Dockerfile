#FROM php:7.4-fpm
FROM public.ecr.aws/docker/library/php:7.4-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip git curl \
    libpng-dev libjpeg-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip mbstring bcmath

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy entire app into container
COPY . .

# Install PHP/Laravel dependencies
RUN composer install --no-interaction --no-dev --prefer-dist && \
    php artisan config:cache && \
    php artisan view:cache
# Do NOT run: php artisan route:cache

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www \
 && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

USER www-data

CMD ["php-fpm"]

