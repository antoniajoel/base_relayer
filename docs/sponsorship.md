# Sponsorship

## Overview

BaseRelayer allows sponsors to pay for user transactions, enabling gasless UX for dApps.

## How It Works

1. **Sponsor Setup**: A sponsor registers in `RelayerHub` with a daily limit
2. **User Request**: User signs a forward request
3. **Relayer Execution**: Relayer executes the transaction, paying gas
4. **Tracking**: Usage is tracked in `RelayerHub`

## Adding a Sponsor

```solidity
// In RelayerHub
function addSponsor(address sponsor, uint256 dailyLimit) external onlyOwner
```

Example:
```solidity
relayerHub.addSponsor(0xYourSponsorAddress, 1000); // 1000 transactions per day
```

## Rate Limits

### Sponsor Limits

Each sponsor has a configurable daily limit. Once reached, no more transactions can be relayed for that sponsor until the limit resets (24 hours).

### User Limits

Each user also has a daily limit (default: 10 transactions per day). This prevents abuse.

## Monitoring Usage

Query sponsor usage:
```solidity
RelayerHub.Sponsor memory sponsor = relayerHub.getSponsor(sponsorAddress);
// sponsor.dailyUsed - transactions used today
// sponsor.dailyLimit - maximum transactions per day
```

Query user usage:
```solidity
RelayerHub.Usage memory usage = relayerHub.getUserUsage(userAddress);
// usage.count - transactions used today
```

## Best Practices

1. **Set appropriate limits**: Balance between UX and cost
2. **Monitor usage**: Track daily usage to prevent abuse
3. **Adjust limits**: Update limits based on actual usage patterns
4. **Allowlist contracts**: Only allowlist trusted contracts to reduce risk

## Cost Estimation

Gas costs on Base are typically:
- Simple transaction: ~21,000 gas
- ERC-20 transfer: ~65,000 gas
- Complex contract call: 100,000+ gas

At current Base gas prices (~0.1 gwei), a transaction costs approximately $0.001-0.01.

## Example: dApp Sponsorship

```typescript
// 1. Add your dApp as a sponsor
await relayerHub.addSponsor(dAppAddress, 1000);

// 2. Users can now send gasless transactions
// 3. Monitor usage daily
const sponsor = await relayerHub.getSponsor(dAppAddress);
console.log(`Used: ${sponsor.dailyUsed}/${sponsor.dailyLimit}`);
```

