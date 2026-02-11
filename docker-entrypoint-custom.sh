#!/bin/bash
set -e

# Start the official WordPress entrypoint in the background
docker-entrypoint.sh apache2-foreground &
WORDPRESS_PID=$!

# Wait for Apache and WordPress files to be ready
echo "Waiting for WordPress files to be ready..."
sleep 10

# Install PG4WP (PostgreSQL for WordPress)
echo "Installing PG4WP..."
if [ ! -f /var/www/html/wp-content/db.php ]; then
    cp /usr/src/pg4wp/db.php /var/www/html/wp-content/
    cp -r /usr/src/pg4wp/driver_pgsql_install.php /var/www/html/wp-content/
    echo "PG4WP installed!"
else
    echo "PG4WP already installed."
fi

# Wait a bit more for database to be ready
echo "Waiting for database connection..."
sleep 20

# Check if WordPress is installed
if ! wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --url="${WORDPRESS_URL:-http://localhost}" \
        --title="${WORDPRESS_TITLE:-WordPress with WPGraphQL}" \
        --admin_user="${WORDPRESS_ADMIN_USER:-admin}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD:-admin123}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL:-admin@example.com}" \
        --allow-root \
        --path=/var/www/html
    
    echo "WordPress installed successfully!"
fi

# Install and activate WPGraphQL plugin
echo "Installing WPGraphQL plugin..."
if ! wp plugin is-installed wp-graphql --allow-root --path=/var/www/html 2>/dev/null; then
    wp plugin install wp-graphql --activate --allow-root --path=/var/www/html
    echo "WPGraphQL plugin installed and activated!"
else
    wp plugin activate wp-graphql --allow-root --path=/var/www/html 2>/dev/null || true
    echo "WPGraphQL plugin already installed, activated!"
fi

echo "WordPress with WPGraphQL and PostgreSQL is ready!"

# Wait for the WordPress process
wait $WORDPRESS_PID
