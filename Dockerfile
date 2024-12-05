# Use the official Ubuntu 22.04 image as base
FROM ubuntu:22.04

# Prevent interactive frontend during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages and PHP 8.2 dependencies
RUN apt-get update && apt-get install -y \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    curl \
    git \
    unzip \
    zip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev

# Add PHP repository and update
RUN add-apt-repository ppa:ondrej/php \
    && apt-get update

# Install PHP 8.2 and required extensions
RUN apt-get install -y \
    php8.2 \
    php8.2-cli \
    php8.2-fpm \
    php8.2-common \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-curl \
    php8.2-zip \
    php8.2-gd \
    php8.2-mysql \
    php8.2-bcmath

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www

# Copy the rest of the application code
COPY . .

# Install Laravel dependencies using Composer
RUN composer install

RUN chmod 777 -Rf storage bootstrap

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

RUN mkdir -p /run/php && chown -R www-data:www-data /run/php
RUN sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = 0.0.0.0:9000/' /etc/php/8.2/fpm/pool.d/www.conf

CMD ["php-fpm8.2", "-F"]
