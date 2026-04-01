#!/bin/bash
set -e

echo "🔧 Setting up superadmin user..."
echo ""

# Get to the API directory
cd "$(dirname "$0")/../apps/api"

echo "📦 Running migrations..."
npm run migration:run

echo ""
echo "👤 Creating superadmin user (vishnu@envsoft.io / Demo@123)..."
npm run seed:superadmin

echo ""
echo "✅ Superadmin setup complete!"
echo ""
echo "Credentials:"
echo "  Email: vishnu@envsoft.io"
echo "  Password: Demo@123"
echo "  Role: superadmin"
