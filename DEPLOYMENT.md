# 🚀 BaseRelayer Deployment Guide

This guide will help you deploy BaseRelayer to Base Sepolia (testnet) and Base Mainnet.

## 📋 Prerequisites

1. **Foundry installed** - [Install Foundry](https://book.getfoundry.sh/getting-started/installation)
2. **Node.js ≥18.x** - For API and frontend
3. **Base Sepolia ETH** - For testnet deployment (get from [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet))
4. **Base Mainnet ETH** - For mainnet deployment
5. **Basescan API Key** - For contract verification (get from [Basescan](https://basescan.org/apis))
6. **WalletConnect Project ID** - For frontend (get from [WalletConnect Cloud](https://cloud.walletconnect.com))

## 🔧 Setup

### 1. Install Dependencies

```bash
npm run install:all
```

### 2. Configure Environment Variables

#### Contracts

```bash
cd contracts
cp .env.example .env
```

Edit `.env`:
```bash
PRIVATE_KEY=your_deployer_private_key
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASE_MAINNET_RPC_URL=https://mainnet.base.org
BASESCAN_API_KEY=your_basescan_api_key
```

#### Relayer

```bash
cd ../relayer
cp .env.example .env
```

Edit `.env`:
```bash
PORT=3002
FORWARDER_ADDRESS=  # Will be set after contract deployment
RELAYER_PRIVATE_KEY=your_relayer_private_key
RPC_URL=https://sepolia.base.org
RELAYER_HUB_ADDRESS=  # Will be set after contract deployment
```

#### Backend

```bash
cd ../backend
cp .env.example .env
```

Edit `.env`:
```bash
PORT=3001
RELAYER_URL=http://localhost:3002
FORWARDER_ADDRESS=  # Will be set after contract deployment
RELAYER_HUB_ADDRESS=  # Will be set after contract deployment
RPC_URL=https://sepolia.base.org
```

#### Frontend

```bash
cd ../frontend
cp .env.example .env.local
```

Edit `.env.local`:
```bash
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_RELAYER_URL=http://localhost:3002
NEXT_PUBLIC_FORWARDER_ADDRESS=  # Will be set after contract deployment
NEXT_PUBLIC_RELAYER_HUB_ADDRESS=  # Will be set after contract deployment
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id
NEXT_PUBLIC_CHAIN_ID=84532  # 84532 for Sepolia, 8453 for Mainnet
```

## 📝 Deploy Smart Contracts

### Deploy to Base Sepolia (Testnet)

```bash
# Make script executable
chmod +x scripts/deploy-sepolia.sh

# Deploy
./scripts/deploy-sepolia.sh
```

Or manually:

```bash
cd contracts

# Set environment variables
export PRIVATE_KEY=your_private_key
export BASESCAN_API_KEY=your_api_key

# Deploy
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base_sepolia \
  --broadcast \
  --verify
```

After deployment, you'll see output like:
```
Forwarder deployed at: 0x...
RelayerHub deployed at: 0x...
```

**Save these addresses!** You'll need them for relayer, backend, and frontend configuration.

### Deploy to Base Mainnet

⚠️ **Warning**: Only deploy to mainnet after thorough testing on Sepolia!

```bash
# Make script executable
chmod +x scripts/deploy-mainnet.sh

# Deploy
./scripts/deploy-mainnet.sh
```

Or manually:

```bash
cd contracts

# Set environment variables
export PRIVATE_KEY=your_private_key
export BASESCAN_API_KEY=your_api_key

# Deploy
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base_mainnet \
  --broadcast \
  --verify
```

## 🔄 Update Configuration After Deployment

### 1. Update Relayer `.env`

```bash
cd relayer
# Edit .env with deployed addresses
FORWARDER_ADDRESS=0x... # from deployment output
RELAYER_HUB_ADDRESS=0x... # from deployment output
```

### 2. Update Backend `.env`

```bash
cd backend
# Edit .env with deployed addresses
FORWARDER_ADDRESS=0x... # from deployment output
RELAYER_HUB_ADDRESS=0x... # from deployment output
```

### 3. Update Frontend `.env.local`

```bash
cd frontend
# Edit .env.local with deployed addresses
NEXT_PUBLIC_FORWARDER_ADDRESS=0x... # from deployment output
NEXT_PUBLIC_RELAYER_HUB_ADDRESS=0x... # from deployment output
NEXT_PUBLIC_CHAIN_ID=84532 # for Sepolia, 8453 for Mainnet
```

## 🚀 Run Services Locally

### Option 1: Start All Services (Recommended)

```bash
chmod +x scripts/start-dev.sh
./scripts/start-dev.sh
```

### Option 2: Start Services Individually

**Terminal 1 - Relayer:**
```bash
cd relayer
npm run dev
```

**Terminal 2 - Backend:**
```bash
cd backend
npm run dev
```

**Terminal 3 - Frontend:**
```bash
cd frontend
npm run dev
```

Services will be available at:
- Relayer: http://localhost:3002
- Backend: http://localhost:3001
- Frontend: http://localhost:3000

## 📦 Deploy Frontend to Vercel

### 1. Install Vercel CLI

```bash
npm i -g vercel
```

### 2. Deploy from Frontend Directory

```bash
cd frontend
vercel
```

Follow the prompts:
- Set up and deploy? **Yes**
- Which scope? Select your account
- Link to existing project? **No**
- Project name? **base-relayer** (or your choice)
- Directory? **./**
- Override settings? **No**

### 3. Add Environment Variables in Vercel Dashboard

1. Go to your project on [Vercel Dashboard](https://vercel.com/dashboard)
2. Go to Settings → Environment Variables
3. Add the following variables:

```
NEXT_PUBLIC_API_URL=https://your-api-url.com
NEXT_PUBLIC_RELAYER_URL=https://your-relayer-url.com
NEXT_PUBLIC_FORWARDER_ADDRESS=0x...
NEXT_PUBLIC_RELAYER_HUB_ADDRESS=0x...
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id
NEXT_PUBLIC_CHAIN_ID=84532
```

4. Redeploy the project

### 4. Update README with Deployment Links

After deployment, update `README.md` with:

```markdown
## 🔗 Links

- **Base Mainnet Forwarder:** [0x...](https://basescan.org/address/0x...)
- **Base Mainnet RelayerHub:** [0x...](https://basescan.org/address/0x...)
- **Base Sepolia Forwarder:** [0x...](https://sepolia.basescan.org/address/0x...)
- **Base Sepolia RelayerHub:** [0x...](https://sepolia.basescan.org/address/0x...)
- **Frontend:** https://base-relayer.vercel.app
- **API:** https://your-api-url.com
```

## ✅ Verification Checklist

After deployment, verify:

- [ ] Contracts deployed and verified on Basescan
- [ ] Relayer can connect to contracts
- [ ] Backend API responds to `/health`
- [ ] Frontend connects to wallet
- [ ] Frontend displays correctly
- [ ] All environment variables set correctly
- [ ] README updated with contract addresses

## 🐛 Troubleshooting

### Contract Deployment Fails

- Check you have enough ETH for gas
- Verify RPC URL is correct
- Ensure private key is correct
- Check Basescan API key is valid

### Relayer Can't Connect

- Verify contract addresses in `.env` are correct
- Check RPC URL is accessible
- Ensure contracts are deployed on the correct network

### Frontend Can't Connect

- Check WalletConnect Project ID is set
- Verify contract addresses in `.env.local`
- Ensure API URL is correct
- Check network/chain ID matches

### Vercel Deployment Fails

- Check all environment variables are set
- Verify build command works locally
- Check Vercel logs for errors

## 📚 Next Steps

1. Test all functionality on Sepolia
2. Get community feedback
3. Deploy to Mainnet when ready
4. Share on Twitter with #BuildOnBase
5. Submit to Base Builder Directory

---

**Need help?** Open an issue on GitHub or reach out to the community!

