# Superadmin User Setup Guide

This guide explains how to create and seed a superadmin user in the Doclyzer application.

## Quick Start

The simplest way to set up the superadmin user is to run the provided setup script:

```bash
./scripts/setup-superadmin.sh
```

This script will:
1. Run all database migrations
2. Create a superadmin user with the following credentials:
   - **Email**: `vishnu@envsoft.io`
   - **Password**: `Demo@123`
   - **Role**: `superadmin`

## Prerequisites

- Docker (for PostgreSQL) and Redis services running via `docker-compose up -d`
- Node.js and npm installed
- `.env` file properly configured with `DATABASE_URL`

## Setup Steps

### 1. Start Services

```bash
docker-compose up -d
```

This starts PostgreSQL and Redis services.

### 2. Run Migrations

```bash
cd apps/api
npm run migration:run
```

This creates all database tables and schemas.

### 3. Seed Superadmin User

```bash
npm run seed:superadmin
```

Or use the all-in-one script:

```bash
./scripts/setup-superadmin.sh
```

## Manual Seed Script

If you want to run the seed script directly with ts-node:

```bash
cd apps/api
npx ts-node src/database/seeds/superadmin.seed.ts
```

## Superadmin Credentials

Once seeded, use these credentials to access the superadmin dashboard:

- **Email**: `vishnu@envsoft.io`
- **Password**: `Demo@123`

## Accessing the Superadmin Dashboard

1. Start the web application:
   ```bash
   cd apps/web
   npm run dev
   ```

2. Navigate to `http://localhost:3001` (or your configured web URL)

3. Login with the superadmin credentials above

4. You should now have access to the superadmin features and MFA elevation challenges

## What Gets Created

The seed script creates:

- A user record with the email `vishnu@envsoft.io`
- Password hashed with bcrypt (10 rounds)
- `emailVerified` flag set to `true`
- Role set to `superadmin`
- Display name: `Superadmin`

## Database Schema

The superadmin user is stored in the `users` table with the following key fields:

| Field | Value |
|-------|-------|
| `id` | UUID (auto-generated) |
| `email` | vishnu@envsoft.io |
| `password_hash` | bcrypt(Demo@123) |
| `email_verified` | true |
| `display_name` | Superadmin |
| `role` | superadmin |
| `created_at` | current timestamp |
| `updated_at` | current timestamp |

## Idempotency

The seed script is idempotent — if you run it multiple times, it will:
- Check if a user with the email already exists
- Skip creation if the user already exists
- Log a message and exit gracefully

## Troubleshooting

### Database Connection Error

If you get a connection error:
1. Ensure PostgreSQL is running: `docker-compose ps`
2. Check `DATABASE_URL` in `.env` is correct
3. Verify credentials match those in `docker-compose.yml`

### Migration Errors

If migrations fail:
1. Check the migration file exists in `src/database/migrations/`
2. Verify database permissions
3. Review PostgreSQL logs: `docker-compose logs postgres`

### Permission Denied on Script

Make the script executable:
```bash
chmod +x ./scripts/setup-superadmin.sh
```

## Environment Variables

Key `.env` variables needed:

```env
DATABASE_URL=postgresql://doclyzer:doclyzer_dev_password@localhost:5432/doclyzer
NODE_ENV=development
```

## Next Steps

After seeding the superadmin user:
1. Access the superadmin dashboard at `/superadmin`
2. Configure MFA settings if needed
3. Add additional superadmins through the admin UI if desired
4. Review audit logs for superadmin actions

## Related Files

- **Seed Script**: `apps/api/src/database/seeds/superadmin.seed.ts`
- **Setup Script**: `scripts/setup-superadmin.sh`
- **User Entity**: `apps/api/src/database/entities/user.entity.ts`
- **Migrations**: `apps/api/src/database/migrations/`
