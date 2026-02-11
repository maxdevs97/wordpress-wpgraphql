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

# Download PG4WP (PostgreSQL for WordPress)
RUN curl -L https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/heads/master.zip -o /tmp/pg4wp.zip && \
    unzip /tmp/pg4wp.zip -d /tmp && \
    mkdir -p /usr/src/pg4wp && \
    cp -r /tmp/postgresql-for-wordpress-master/pg4wp/* /usr/src/pg4wp/ && \
    rm -rf /tmp/pg4wp.zip /tmp/postgresql-for-wordpress-master

# Copy custom entrypoint script
COPY docker-entrypoint-custom.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh

# Use custom entrypoint that wraps the official one
ENTRYPOINT ["docker-entrypoint-custom.sh"]
CMD ["apache2-foreground"]
