# BaseRelayer

[![Built for Base](https://img.shields.io/badge/Built%20for-Base-0052FF)](https://base.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Open-source transaction relayer & meta-tx infrastructure for Base**

BaseRelayer is a **public, non-custodial transaction relayer** for Base that lets users and dApps send gasless or sponsored transactions, batch calls, and scheduled executions — built as a clean, open infrastructure primitive.

## 🎯 Overview

BaseRelayer improves UX for Base ecosystem by enabling:
- **Gasless transactions** - Users can interact with dApps without holding ETH
- **Sponsored calls** - dApps can sponsor user transactions
- **Batching** - Execute multiple calls in a single transaction
- **Scheduled executions** - Time or block-based transaction scheduling
- **Allowlisted contracts** - Secure, controlled access to specific contracts

## 🔗 Links

- **Chain ID:** 8453 (Base Mainnet), 84532 (Base Sepolia)
- **Network:** [Base](https://base.org)
- **Explorer:** [Basescan](https://basescan.org)
- **Documentation:** [docs/](./docs/)
- **Frontend Playground:** (Coming soon)
- **API:** (Coming soon)

## 🏗️ Architecture

```
User signs intent → relayer validates → tx executed on Base → receipt returned
```

### Project Structure

```
/baserelayer
├── contracts/          # Smart contracts (Forwarder, RelayerHub)
├── relayer/            # Relayer server (validator, executor)
├── backend/            # REST API
├── frontend/           # Playground UI
├── sdk/                # JavaScript SDK
└── docs/               # Documentation
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** ≥18.x
- **Foundry** ([Install](https://book.getfoundry.sh/getting-started/installation))
- **Git**

### Installation

```bash
# Clone repository
git clone https://github.com/antoniajoel/base_relayer.git
cd base_relayer

# Install all dependencies
npm run install:all
```

### Development

```bash
# Build contracts
npm run build:contracts

# Run tests
npm run test:contracts

# Start relayer server
cd relayer && npm run dev

# Start API
cd backend && npm run dev

# Start frontend
cd frontend && npm run dev
```

## 📖 Documentation

- [Security](./docs/security.md) - Security considerations
- [Sponsorship](./docs/sponsorship.md) - How sponsorship works
- [Integrations](./docs/integrations.md) - Integration guide
- [API Reference](./docs/api.md) - REST API documentation

## 🔧 Smart Contracts

### Forwarder.sol

EIP-2771 compatible forwarder for meta-transactions.

```solidity
struct ForwardRequest {
    address from;
    address to;
    uint256 value;
    uint256 gas;
    uint256 nonce;
    bytes data;
}
```

### RelayerHub.sol

Manages sponsors, tracks usage, and enforces limits.

## 🌐 API

### Endpoints

- `POST /relay` - Submit a transaction for relaying
- `GET /status/:txHash` - Get transaction status
- `GET /limits` - Get rate limits
- `GET /stats` - Get relayer statistics

See [API Documentation](./docs/api.md) for details.

## 📦 SDK

```typescript
import { BaseRelayer } from "@baserelayer/sdk";

const client = new BaseRelayer({
  apiUrl: "https://api.baserelayer.xyz",
  chainId: 8453
});

await client.sendGaslessTx({
  to: "0x...",
  data: "0x...",
});
```

## 🛡️ Security

BaseRelayer is non-custodial - we never hold user funds. All transactions are validated on-chain before execution. See [Security Documentation](./docs/security.md) for details.

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and code of conduct.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 Roadmap

### Phase 1: MVP ✅
- [x] Forwarder contract
- [x] RelayerHub contract
- [x] Relayer server
- [x] Basic API
- [x] Playground UI
- [ ] Base Sepolia deployment

### Phase 2: Production
- [ ] Base Mainnet deployment
- [ ] Advanced sponsorship rules
- [ ] Transaction batching
- [ ] Scheduled executions
- [ ] SDK release
- [ ] Comprehensive documentation

### Phase 3: Ecosystem
- [ ] Multiple relayer nodes
- [ ] Analytics dashboard
- [ ] Integration examples
- [ ] Community feedback

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## 🙏 Acknowledgments

- Built for [Base](https://base.org)
- Inspired by EIP-2771 and OpenGSN
- Community feedback and contributions

---

**Built for Base** | Chain ID: 8453 | [Base Explorer](https://basescan.org)

