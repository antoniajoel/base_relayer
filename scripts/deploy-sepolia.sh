#!/bin/bash

# Deploy BaseRelayer contracts to Base Sepolia

set -e

echo "🚀 Deploying BaseRelayer to Base Sepolia..."
echo ""

cd "$(dirname "$0")/../contracts"

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    echo "Please create .env file with PRIVATE_KEY, BASE_SEPOLIA_RPC_URL, and BASESCAN_API_KEY"
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

echo "🚀 Deploying to Base Sepolia..."
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url base_sepolia \
    --broadcast \
    --verify \
    -vvv

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 Save the contract addresses from the output above"
echo "   You'll need them for API and frontend configuration"

