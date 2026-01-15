#!/bin/bash

# Deploy BaseRelayer contracts to Base Mainnet

set -e

echo "🚀 Deploying BaseRelayer to Base Mainnet..."
echo ""
echo "⚠️  WARNING: This will deploy to MAINNET!"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

cd "$(dirname "$0")/../contracts"

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    echo "Please create .env file with PRIVATE_KEY, BASE_MAINNET_RPC_URL, and BASESCAN_API_KEY"
    exit 1
fi

# Load environment variables
source .env

# Check required variables
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Error: PRIVATE_KEY not set in .env"
    exit 1
fi

if [ -z "$BASESCAN_API_KEY" ]; then
    echo "⚠️  Warning: BASESCAN_API_KEY not set, contracts will not be verified"
fi

echo "📦 Installing dependencies..."
forge install

echo "🔨 Building contracts..."
forge build

echo "🚀 Deploying to Base Mainnet..."
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url base_mainnet \
    --broadcast \
    --verify \
    -vvv

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 Save the contract addresses from the output above"
echo "   You'll need them for API and frontend configuration"

