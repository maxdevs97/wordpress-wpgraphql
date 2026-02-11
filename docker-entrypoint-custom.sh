#!/bin/bash
set -e

# Run the official WordPress entrypoint to set up files and start Apache
# PG4WP is already in /usr/src/wordpress/wp-content/ and will be copied automatically
docker-entrypoint.sh apache2-foreground &
APACHE_PID=$!

# Wait for WordPress files to be ready
echo "Waiting for WordPress to initialize..."
sleep 15

# Wait for database to be responsive
echo "Checking database connectivity..."
max_attempts=30
attempt=0
until wp db check --allow-root --path=/var/www/html 2>/dev/null || [ $attempt -eq $max_attempts ]; do
    attempt=$((attempt + 1))
    echo "Waiting for database (attempt $attempt/$max_attempts)..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "ERROR: Database not accessible after $max_attempts attempts"
    echo "Host: ${WORDPRESS_DB_HOST}"
    exit 1
fi

echo "✓ Database connected!"

# Install WordPress if needed
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
    
    echo "✓ WordPress installed!"
else
    echo "✓ WordPress already installed"
fi

# Install and activate WPGraphQL
echo "Setting up WPGraphQL..."
if ! wp plugin is-installed wp-graphql --allow-root --path=/var/www/html 2>/dev/null; then
    wp plugin install wp-graphql --activate --allow-root --path=/var/www/html
    echo "✓ WPGraphQL installed and activated!"
else
    wp plugin activate wp-graphql --allow-root --path=/var/www/html 2>/dev/null || true
    echo "✓ WPGraphQL already active"
fi

echo ""
echo "================================================"
echo "✓ WordPress with WPGraphQL is ready!"
echo "✓ Site: ${WORDPRESS_URL}"
echo "✓ GraphQL endpoint: ${WORDPRESS_URL}/graphql"
echo "================================================"

# Keep the container running
wait $APACHE_PID
