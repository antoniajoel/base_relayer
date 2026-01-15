# Integrations

## Overview

This guide shows how to integrate BaseRelayer into your dApp.

## Installation

```bash
npm install @baserelayer/sdk
```

## Basic Usage

```typescript
import { BaseRelayer } from "@baserelayer/sdk";

const relayer = new BaseRelayer({
  apiUrl: "https://api.baserelayer.xyz",
  chainId: 8453, // Base Mainnet
});
```

## Sending Gasless Transactions

### 1. Create Forward Request

```typescript
import { ethers } from "ethers";

const forwarder = new ethers.Contract(
  FORWARDER_ADDRESS,
  FORWARDER_ABI,
  signer
);

const request = {
  from: userAddress,
  to: targetContract,
  value: 0,
  gas: 100000,
  nonce: await forwarder.getNonce(userAddress),
  data: calldata,
};
```

### 2. Sign Request

```typescript
// Using EIP-712
const domain = {
  name: "BaseRelayer",
  version: "1",
  chainId: 8453,
  verifyingContract: FORWARDER_ADDRESS,
};

const types = {
  ForwardRequest: [
    { name: "from", type: "address" },
    { name: "to", type: "address" },
    { name: "value", type: "uint256" },
    { name: "gas", type: "uint256" },
    { name: "nonce", type: "uint256" },
    { name: "data", type: "bytes" },
  ],
};

const signature = await signer.signTypedData(domain, types, request);
```

### 3. Relay Transaction

```typescript
const result = await relayer.sendGaslessTxWithSignature(request, signature);

if (result.success) {
  console.log("Transaction hash:", result.txHash);
} else {
  console.error("Error:", result.error);
}
```

## Checking Transaction Status

```typescript
const status = await relayer.getStatus(txHash);
console.log("Status:", status.status); // "pending" | "confirmed" | "failed"
```

## Rate Limits

```typescript
const limits = await relayer.getLimits(userAddress);
console.log("Daily limit:", limits.userDailyLimit);
console.log("Used today:", limits.userUsed);
```

## Example: ERC-20 Transfer

```typescript
// 1. Prepare transfer calldata
const erc20 = new ethers.Contract(tokenAddress, ERC20_ABI, signer);
const calldata = erc20.interface.encodeFunctionData("transfer", [
  recipient,
  amount,
]);

// 2. Create forward request
const request = {
  from: userAddress,
  to: tokenAddress,
  value: 0,
  gas: 100000,
  nonce: await forwarder.getNonce(userAddress),
  data: calldata,
};

// 3. Sign and relay
const signature = await signer.signTypedData(domain, types, request);
const result = await relayer.sendGaslessTxWithSignature(request, signature);
```

## React Hook Example

```typescript
import { useSignTypedData } from "wagmi";
import { BaseRelayer } from "@baserelayer/sdk";

function useGaslessTx() {
  const { signTypedDataAsync } = useSignTypedData();
  const relayer = new BaseRelayer({
    apiUrl: process.env.NEXT_PUBLIC_API_URL!,
    chainId: 8453,
  });

  const sendTx = async (to: string, data: string) => {
    // Get nonce
    const nonce = await getNonce(userAddress);

    // Create request
    const request = {
      from: userAddress,
      to,
      value: 0,
      gas: 100000,
      nonce,
      data,
    };

    // Sign
    const signature = await signTypedDataAsync({
      domain,
      types,
      primaryType: "ForwardRequest",
      message: request,
    });

    // Relay
    return await relayer.sendGaslessTxWithSignature(request, signature);
  };

  return { sendTx };
}
```

## Best Practices

1. **Error Handling**: Always handle errors and show user-friendly messages
2. **Loading States**: Show loading indicators during transaction relay
3. **Status Polling**: Poll transaction status until confirmed
4. **Rate Limit Checks**: Check limits before attempting to relay
5. **Gas Estimation**: Estimate gas accurately to avoid failures

