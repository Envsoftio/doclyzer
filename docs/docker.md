# Docker Setup

This project currently provides a Docker baseline for infrastructure services:

- PostgreSQL (`postgres:16-alpine`)
- Redis (`redis:7-alpine`)
- Optional Adminer (`adminer:4`, `ops` profile)

## Quick Start

1. Create env file:

```bash
cp .env.docker.example .env
```

2. Start core services:

```bash
docker compose up -d
```

3. (Optional) Start Adminer too:

```bash
docker compose --profile ops up -d
```

4. Verify:

```bash
docker compose ps
```

## Connection Defaults

- Postgres host: `localhost`
- Postgres port: `5432`
- DB name: `doclyzer`
- User: `doclyzer`
- Password: `doclyzer_dev_password`
- Redis host: `localhost`
- Redis port: `6379`

## Notes

- App services (NestJS API, Nuxt, parser/LLM containers) are not wired yet because app code scaffolds are not present in this repository root.
- Add those services to `docker-compose.yml` after app scaffolding is generated.
