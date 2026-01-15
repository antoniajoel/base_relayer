# API Reference

## Base URL

```
https://api.baserelayer.xyz
```

## Endpoints

### POST /relay

Submit a transaction for relaying.

**Request Body:**
```json
{
  "request": {
    "from": "0x...",
    "to": "0x...",
    "value": "0",
    "gas": "100000",
    "nonce": "0",
    "data": "0x..."
  },
  "signature": "0x...",
  "sponsor": "0x..." // optional
}
```

**Response:**
```json
{
  "success": true,
  "txHash": "0x..."
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Invalid signature"
}
```

### GET /status/:txHash

Get transaction status.

**Response:**
```json
{
  "hash": "0x...",
  "status": "confirmed",
  "blockNumber": 12345,
  "gasUsed": "21000"
}
```

**Status Values:**
- `pending` - Transaction is pending
- `confirmed` - Transaction confirmed
- `failed` - Transaction failed

### GET /limits

Get rate limits for an address.

**Query Parameters:**
- `address` - User or sponsor address

**Response:**
```json
{
  "userDailyLimit": 10,
  "userUsed": 3,
  "defaultDailyLimit": 100
}
```

### GET /stats

Get relayer statistics.

**Response:**
```json
{
  "relayer": {
    "address": "0x...",
    "balance": "1000000000000000000",
    "chainId": 8453,
    "forwarder": "0x..."
  },
  "forwarder": "0x...",
  "hub": "0x...",
  "chainId": "8453"
}
```

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "chainId": 8453
}
```

## Error Codes

- `400` - Bad Request (invalid signature, missing fields)
- `404` - Not Found (transaction not found)
- `500` - Internal Server Error

## Rate Limiting

API requests are rate-limited. If you exceed the limit, you'll receive a `429 Too Many Requests` response.

