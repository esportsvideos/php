# PHP Docker Image

This repository contains Docker configurations to build base images for both production and development environments using PHP, Composer, and Alpine Linux.
The build process is managed automatically by GitHub Actions, generating two distinct images (X.X.X & X.X.X-dev).

## Versions

| Component | Version |
|-----------|---------|
| Alpine    | 3.21    |
| PHP       | 8.4.6   |
| Composer  | 2.8.8   |

## Production Image

The production image is optimized for running Symfony applications in a production environment. It includes:

- PHP-FPM with Alpine Linux
- Composer for dependency management
- Required PHP extensions: `zip`, `intl`, `exif`, `pdo_pgsql`, and `redis`
- Production-optimized PHP configuration (`php.ini-production`)
- [Symfony-specific configurations for enhanced performance](https://symfony.com/doc/current/performance.html)

### Image Link:

https://github.com/orgs/esportsvideos/php/pkgs/container/php

```
docker pull ghcr.io/esportsvideos/php:X.X.X
```

## Development Image

The development image extends the production image with additional tools and configurations for a development environment:

- Xdebug for debugging
- su-exec for better process management
- Custom entrypoint script to handle volume sharing issues

### Image Link:

https://github.com/orgs/esportsvideos/php/pkgs/container/php

```
docker pull ghcr.io/esportsvideos/php:X.X.X-dev
```


## Configuration

### PHP Configuration

- Production: Uses `php.ini-production` and includes Symfony-specific settings.
- Development: Uses `php.ini-development` and includes Xdebug settings.

### Custom Entrypoint

The development image includes a custom entrypoint script (`docker-entrypoint.dev.sh`) to handle volume sharing issues.

## License

This project is under the MIT license. [See the complete license](LICENSE)
