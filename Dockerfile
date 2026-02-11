FROM wordpress:latest

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Install required tools and PostgreSQL support
RUN apt-get update && apt-get install -y \
    less \
    mariadb-client \
    libpq-dev \
    postgresql-client \
    && docker-php-ext-install pgsql pdo_pgsql \
    && rm -rf /var/lib/apt/lists/*

# Copy PG4WP files directly into WordPress source
# This ensures PostgreSQL support is available before WordPress initializes
COPY pg4wp/ /usr/src/wordpress/wp-content/
RUN chown -R www-data:www-data /usr/src/wordpress/wp-content

# Copy custom entrypoint script
COPY docker-entrypoint-custom.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh

ENTRYPOINT ["docker-entrypoint-custom.sh"]
CMD ["apache2-foreground"]
