#!/bin/bash
set -e

# Start the official WordPress entrypoint in the background
docker-entrypoint.sh apache2-foreground &
WORDPRESS_PID=$!

# Wait for WordPress to be ready
echo "Waiting for WordPress to be ready..."
sleep 30

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

# Wait for the WordPress process
wait $WORDPRESS_PID
