# WordPress with WPGraphQL

Fresh WordPress installation with WPGraphQL plugin pre-configured.

## Endpoints

- **WordPress Admin**: `https://[app-url]/wp-admin`
- **GraphQL Endpoint**: `https://[app-url]/graphql`

## Default Credentials

- **Username**: admin
- **Password**: WPGraphQL2026!

## WPGraphQL Plugin

The WPGraphQL plugin is automatically installed and activated on deployment.

GraphQL endpoint is available at `/graphql` and supports introspection queries.

## Testing GraphQL

```bash
curl -X POST https://[app-url]/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __schema { types { name } } }"}'
```

## Local Development

```bash
docker build -t wordpress-wpgraphql .
docker run -p 8080:80 \
  -e WORDPRESS_DB_HOST=host.docker.internal:3306 \
  -e WORDPRESS_DB_USER=root \
  -e WORDPRESS_DB_PASSWORD=password \
  -e WORDPRESS_DB_NAME=wordpress \
  wordpress-wpgraphql
```
