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
    unzip \
    && docker-php-ext-install pgsql pdo_pgsql \
    && rm -rf /var/lib/apt/lists/*

# Download and install PG4WP directly into WordPress source
# This ensures it's available before WordPress tries to connect to the database
RUN cd /usr/src/wordpress && \
    curl -L https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/heads/master.zip -o /tmp/pg4wp.zip && \
    unzip /tmp/pg4wp.zip -d /tmp && \
    mkdir -p /usr/src/wordpress/wp-content && \
    cp /tmp/postgresql-for-wordpress-master/pg4wp/db.php /usr/src/wordpress/wp-content/ && \
    cp /tmp/postgresql-for-wordpress-master/pg4wp/driver_pgsql_install.php /usr/src/wordpress/wp-content/ && \
    rm -rf /tmp/pg4wp.zip /tmp/postgresql-for-wordpress-master && \
    chown -R www-data:www-data /usr/src/wordpress/wp-content

# Copy custom entrypoint script
COPY docker-entrypoint-custom.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh

ENTRYPOINT ["docker-entrypoint-custom.sh"]
CMD ["apache2-foreground"]
