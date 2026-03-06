# Docker Setup

This project currently provides a Docker baseline for infrastructure services:

- PostgreSQL (`postgres:alpine` — latest)
- Redis (`redis:alpine` — latest)

## Quick Start

1. Create env file:

```bash
cp .env.docker.example .env
```

2. Start core services:

```bash
docker compose up -d
```

3. Verify:

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

## Accessing DB from your client via SSH tunnel

From your local machine, tunnel to the server so Postgres is reachable as `localhost:5432`:

```bash
ssh -L 5432:localhost:5432 user@your-server-host
```

Then connect with any client (psql, DBeaver, etc.) to `localhost:5432` using the same DB/user/password. If Postgres on the server already uses 5432, pick a different local port:

```bash
ssh -L 15432:localhost:5432 user@your-server-host
```

Connect to `localhost:15432` from your client.

## Notes

- App services (NestJS API, Nuxt, parser/LLM containers) are not wired yet because app code scaffolds are not present in this repository root.
- Add those services to `docker-compose.yml` after app scaffolding is generated.
