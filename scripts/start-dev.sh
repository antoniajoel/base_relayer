#!/bin/bash

# Start all services for local development

set -e

echo "🚀 Starting BaseRelayer development environment..."
echo ""

# Check if .env files exist
if [ ! -f "relayer/.env" ]; then
    echo "⚠️  Warning: relayer/.env not found, creating from example..."
    cp relayer/.env.example relayer/.env
    echo "   Please update relayer/.env with your configuration"
fi

if [ ! -f "backend/.env" ]; then
    echo "⚠️  Warning: backend/.env not found, creating from example..."
    cp backend/.env.example backend/.env
    echo "   Please update backend/.env with your configuration"
fi

if [ ! -f "frontend/.env.local" ]; then
    echo "⚠️  Warning: frontend/.env.local not found, creating from example..."
    cp frontend/.env.example frontend/.env.local
    echo "   Please update frontend/.env.local with your configuration"
fi

echo "📦 Installing dependencies..."
npm run install:all

echo ""
echo "🌐 Starting services..."
echo ""
echo "   Relayer:    http://localhost:3002"
echo "   Backend:    http://localhost:3001"
echo "   Frontend:   http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Start services in background
cd relayer && npm run dev &
RELAYER_PID=$!

cd ../backend && npm run dev &
BACKEND_PID=$!

cd ../frontend && npm run dev &
FRONTEND_PID=$!

# Wait for interrupt
trap "kill $RELAYER_PID $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT TERM

wait

