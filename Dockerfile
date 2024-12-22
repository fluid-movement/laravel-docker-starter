FROM php:8.4-apache

# Set host user and group IDs
ARG UID=1000
ARG GID=1000

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    gnupg \
    && docker-php-ext-install pdo pdo_mysql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs \
    && npm install -g npm@latest

# Install Composer as root (shared globally)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create a non-root user and set permissions
RUN if ! getent group ${GID} >/dev/null; then groupadd -g ${GID} appgroup; fi && \
    if ! id -u ${UID} >/dev/null 2>&1; then useradd -m -u ${UID} -g appgroup appuser; fi && \
    mkdir -p /home/appuser/.composer && \
    chown -R appuser:appgroup /home/appuser/.composer && \
    mkdir -p /var/www/html && \
    chown -R appuser:appgroup /var/www/html

# Set DocumentRoot to Laravel's public directory in Apache
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Enable Apache rewrite module for Laravel routing
RUN a2enmod rewrite

# Switch to the new user
USER appuser

# Install Laravel Installer as non-root user
RUN composer global require laravel/installer --no-progress --no-suggest

# Ensure Laravel CLI is available for the new user
ENV PATH="/home/appuser/.composer/vendor/bin:$PATH" \
    NODE_PATH="/usr/lib/node_modules"