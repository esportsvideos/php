# PHP Docker Image

This repository contains Docker configurations to build base images for both production and development environments using PHP, Composer, and Alpine Linux.
The build process is managed automatically by GitHub Actions, generating two distinct images (`X.X.X-YYYYMMDD-rN` & `X.X.X-YYYYMMDD-rN-dev`).

## Versions

| Component | Version |
|-----------|---------|
| Alpine    | 3.23    |
| PHP       | 8.5.7   |
| Composer  | 2.10.1  |

## Image tags

Tags follow the format `X.X.X-YYYYMMDD-rN` (PHP version + build date + build revision for the day, starting at `r1`).

| Tag                 | Description                                                               |
|---------------------|---------------------------------------------------------------------------|
| `8.5.7-20260616-r1` | Exact build — the only published tag. Pin this everywhere it is consumed. |

Append `-dev` for the development variant (e.g. `8.5.7-20260616-r1-dev`).

Only immutable, exact tags are published (no floating `latest` / `8.5` / `8`). Consumers pin the exact tag; version bumps are expected to land as reviewed pull requests on the consuming repositories.

### Rebuild schedule

Images are automatically rebuilt every Monday to include the latest Alpine package updates.
A new tag with the current date and an incremented `-rN` suffix is pushed on each rebuild (same-day rebuilds bump `N`).

### PHP version updates

PHP, Composer, and Alpine version bumps are handled manually: update the `ARG` values in the `Dockerfile`, commit to `main`, then trigger the `Build and Release` workflow via the Actions tab (`workflow_dispatch`). The workflow computes the tag from the `Dockerfile` ARG and publishes the release.

## Production Image

The production image is optimized for running Symfony applications in a production environment. It includes:

- PHP-FPM with Alpine Linux
- Composer for dependency management
- Required PHP extensions: `zip`, `intl`, `exif`, `redis` and `pdo_pgsql`
- Production-optimized PHP configuration (`php.ini-production`)
- [Symfony-specific configurations for enhanced performance](https://symfony.com/doc/current/performance.html)

### Image Link:

[https://github.com/orgs/esportsvideos/php/pkgs/container/php](https://github.com/esportsvideos/php/pkgs/container/php)

```
docker pull ghcr.io/esportsvideos/php:8.5.7-20260324-r1
```

## Development Image

The development image extends the production image with additional tools and configurations for a development environment:

- `Xdebug` for debugging
- `su-exec` for better process management
- Custom entrypoint script to handle volume sharing issues

### Image Link:

[https://github.com/orgs/esportsvideos/php/pkgs/container/php](https://github.com/orgs/esportsvideos/php/pkgs/container/php)

```
docker pull ghcr.io/esportsvideos/php:8.5.7-20260324-r1-dev
```


## Configuration

### PHP Configuration

- Production: Uses `php.ini-production` and includes Symfony-specific settings.
- Development: Uses `php.ini-development` and includes Xdebug settings.

### Custom Entrypoint

The development image includes a custom entrypoint script (`docker-entrypoint.dev.sh`) to handle volume sharing issues.

## License

This project is under the MIT license. [See the complete license](LICENSE)
