# Doclyzer

A full-stack application for document management and analysis.

## Project Structure

This is a **monorepo** with three main applications:

- **API** (`apps/api/`) - NestJS backend server
- **Web** (`apps/web/`) - Nuxt 4 frontend application
- **Mobile** (`apps/mobile/`) - Flutter mobile app

## Prerequisites

- Node.js (v18+) & npm
- Docker & Docker Compose
- Flutter SDK (for mobile development)
- Git

## Quick Start

### 1. Setup Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# The .env file includes defaults for local development:
# - PostgreSQL: localhost:5432
# - Redis: localhost:6379
# - API: http://localhost:4000
# - Web: http://localhost:3001
```

### 2. Start API + Database Stack with Docker Compose

```bash
# Start API + PostgreSQL (+ Redis + Docling dependencies)
docker compose up -d api postgres

# Verify services are running
docker compose ps
```

### 3. Run the API (Backend)

```bash
cd apps/api

# Install dependencies
npm install

# Run database migrations
npm run migration:run

# Start development server
npm run start:dev
```

Alternative: if `api` service is already started via compose in Step 2, API is available at **http://localhost:4000** without running these commands.

### 4. Run the Web App (Frontend)

```bash
cd apps/web

# Install dependencies
npm install

# Start development server
npm run dev
```

The web app will be available at **http://localhost:3001**

### 5. Run the Mobile App (Optional)

```bash
cd apps/mobile

# Get Flutter dependencies
flutter pub get

# Run on Android emulator/device
flutter run -d emulator-5554  # Replace with your device ID

# Or run on iOS simulator
flutter run -d "iPhone 15"
```

## Running Everything in Parallel

Open separate terminal windows for each service:

```bash
# Terminal 1: API + Infra
docker compose up

# Terminal 2: API
cd apps/api && npm install && npm run start:dev

# Terminal 3: Web
cd apps/web && npm install && npm run dev

# Terminal 4: Mobile (if needed)
cd apps/mobile && flutter pub get && flutter run
```

## Common Commands

### API Commands

```bash
# Development
npm run start:dev

# Production build
npm run start:prod

# Run unit tests
npm run test

# Run e2e tests
npm run test:e2e

# Test coverage
npm run test:cov
```

### Web Commands

```bash
# Development
npm run dev

# Build for production
npm run build

# Generate static site
npm run generate

# Preview production build
npm run preview
```

### Docker Compose Commands

```bash
# Start services
docker compose up

# Start in background
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs

# View specific service logs
docker compose logs api
docker compose logs postgres
docker compose logs redis
```

## Environment Configuration

Key environment variables (see `.env.example` for full list):

```bash
# Database
DATABASE_URL=postgresql://doclyzer:doclyzer_dev_password@localhost:5432/doclyzer

# Better Auth
BETTER_AUTH_SECRET=change-me-in-production
BETTER_AUTH_URL=http://localhost:4000
BETTER_AUTH_BASE_PATH=/v1/auth

# Backblaze B2 Storage (optional)
B2_DISABLED=true  # Set to false and configure B2_* vars for production

# Payment Gateway
RAZORPAY_KEY_ID=rzp_test_xxxxx
RAZORPAY_KEY_SECRET=change-me-in-production
```

## Development Workflow

### API Development
- API code is in `apps/api/src/`
- Database migrations are in `apps/api/src/database/migrations/`
- NestJS modules are organized by feature in `apps/api/src/modules/`

### Web Development
- Web code is in `apps/web/`
- Uses Nuxt 4 with Vue 3
- Auto hot-module replacement (HMR) enabled in dev mode

### Mobile Development
- Mobile code is in `apps/mobile/`
- Built with Flutter
- Android and iOS support

## Troubleshooting

### Database Connection Issues
```bash
# Check if PostgreSQL is running
docker compose ps

# Restart PostgreSQL
docker compose restart postgres

# View PostgreSQL logs
docker compose logs postgres
```

### Port Already in Use
If ports are already in use, modify `.env`:
```bash
# Change ports in .env
POSTGRES_PORT=5433
REDIS_PORT=6380
```

Then restart containers:
```bash
docker compose down
docker compose up -d
```

### Dependencies Issues
```bash
# Clear npm cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

## License

[See LICENSE file](./LICENSE) for details.
