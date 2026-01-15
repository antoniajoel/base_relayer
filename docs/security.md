# Security

## Overview

BaseRelayer is designed with security as a top priority. This document outlines the security considerations and best practices.

## Non-Custodial Design

BaseRelayer is **non-custodial** - we never hold user funds. All transactions are executed directly on-chain, and users maintain full control of their assets.

## Signature Verification

All forward requests are verified on-chain using EIP-712 typed data signing:

1. User signs a `ForwardRequest` using EIP-712
2. Relayer verifies the signature on-chain before execution
3. Nonce prevents replay attacks

## Rate Limiting

The `RelayerHub` contract enforces rate limits:

- **Sponsor limits**: Each sponsor has a daily transaction limit
- **User limits**: Each user has a daily transaction limit
- **Automatic reset**: Limits reset daily

## Contract Allowlisting

Contracts can be allowlisted in `RelayerHub` to restrict which contracts can receive relayed transactions. This provides an additional layer of security.

## Best Practices

### For Users

1. **Verify requests**: Always verify the forward request before signing
2. **Check nonces**: Ensure nonces are sequential
3. **Review gas limits**: Set appropriate gas limits to prevent excessive spending

### For Sponsors

1. **Set limits**: Configure appropriate daily limits
2. **Monitor usage**: Track relayed transactions
3. **Allowlist contracts**: Only allowlist trusted contracts

### For Developers

1. **Validate inputs**: Always validate forward requests
2. **Handle errors**: Properly handle failed transactions
3. **Monitor events**: Listen to `TransactionRelayed` events

## Audit Status

⚠️ **BaseRelayer is in early development and has not been audited yet.**

Before using in production:

1. Conduct a security audit
2. Review all smart contract code
3. Test thoroughly on testnets
4. Start with small limits

## Reporting Security Issues

If you discover a security vulnerability, please email security@baserelayer.xyz (or create a private security advisory on GitHub).

**Do not** open public issues for security vulnerabilities.

