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
# - API: http://localhost:4002
# - Web: http://localhost:3005
```

Set `B2_KEY_ID`, `B2_APPLICATION_KEY`, and `B2_BUCKET_NAME` in `.env`.
Background report processing requires durable B2 storage.

### 2. Start API, Worker, and Database Stack with Docker Compose

```bash
# Build the API, apply migrations, and start the API, worker, dispatcher, and dependencies
docker compose up -d

# Verify all services are running and processing is healthy
docker compose ps
curl http://localhost:4002/v1/health/report-processing
```

The health response should be `{"enabled":true,"healthy":true}`. Compose
restarts the worker and dispatcher after a crash.

For PDFs, the worker runs Docling's full-document `auto` OCR pass with the
accurate TableFormer preset and table cell matching. It uses page-level
Tesseract only when the full-document result is incomplete, and accepts those
rows only when existing observations survive unchanged. Unresolved PDF pages
require review; original JPEG/PNG uploads use PaddleOCR. Set a
nonempty `LAB_OCR_API_KEY` in `.env`, then start the default Compose stack:

```bash
docker compose up -d --build
```

The worker checkpoints Docling conversion and fallback results. Unresolved rows
require source review. PaddleOCR-VL table review is optional;
see [lab geometry pilot](docs/implementation-tasks/lab-geometry-pilot.md).

After changing API source, recreate the build job and services to refresh
their shared compiled code:

```bash
docker compose up -d --force-recreate api-build api report-worker report-dispatcher
```

### 3. Run the API outside Docker (Optional)

```bash
cd apps/api

# Install dependencies
npm install

# Run database migrations
npm run migration:run

# Run with REPORT_ASYNC_RUNTIME_ENABLED=true and the worker/dispatcher available
REPORT_ASYNC_RUNTIME_ENABLED=true REPORT_ASYNC_ACCEPTANCE_ENABLED=true npm run start:dev
```

The Compose API from Step 2 is already available at **http://localhost:4002**.
Stop that API container before running a second server on the same port.

### 4. Run the Web App (Frontend)

```bash
cd apps/web

# Install dependencies
npm install

# Start development server
npm run dev
```

The web app will be available at **http://localhost:3005**

### 5. Run the Mobile App (Optional)

```bash
cd apps/mobile

# Get Flutter dependencies
flutter pub get

# Run on Android emulator/device
flutter run -d emulator-5554  # Replace with your device ID

# Or run on iOS simulator
flutter run -d "iPhone 15"

# Physical Android or iPhone on the same Wi-Fi as this computer:
# Find this computer's LAN IP (macOS: ipconfig getifaddr en0).
# Replace the example IP and device ID with your own values.
flutter devices
flutter run -d DEVICE_ID --dart-define=API_BASE_URL=http://192.168.1.28:4002
```

For a physical device, open `http://YOUR_COMPUTER_LAN_IP:4002/v1/incidents/active`
in its browser before signing in. If it does not respond, check that the API
is running on port 4002 and that the computer firewall and Wi-Fi allow devices
to reach each other. The local HTTP allowance is present in Android and iOS
debug builds only; release builds should use an HTTPS API URL. A plain
`flutter run` on a physical Android device uses the emulator address
`10.0.2.2` and cannot reach the computer's API; pass `API_BASE_URL` each time.

## Running Everything in Parallel

Open separate terminal windows for the backend stack and web client:

```bash
# Terminal 1: API + Infra
docker compose up

# Terminal 2: Web
cd apps/web && npm install && npm run dev

# Terminal 3: Mobile (if needed)
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
BETTER_AUTH_URL=http://localhost:4002
BETTER_AUTH_BASE_PATH=/v1/auth

# Backblaze B2 Storage (required for report processing)
B2_DISABLED=false
B2_KEY_ID=...
B2_APPLICATION_KEY=...
B2_BUCKET_NAME=...

# Async processing is on in the default Compose stack
REPORT_ASYNC_RUNTIME_ENABLED=true
REPORT_ASYNC_ACCEPTANCE_ENABLED=true

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
