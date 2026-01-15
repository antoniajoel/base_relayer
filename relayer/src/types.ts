export namespace Forwarder {
  export interface ForwardRequest {
    from: string;
    to: string;
    value: bigint | string;
    gas: bigint | string;
    nonce: bigint | string;
    data: string;
  }
}

export interface RelayRequest {
  request: Forwarder.ForwardRequest;
  signature: string;
  sponsor?: string;
}

export interface RelayResponse {
  success: boolean;
  txHash?: string;
  error?: string;
}

export interface TransactionStatus {
  hash: string;
  status: "pending" | "confirmed" | "failed";
  blockNumber?: number;
  gasUsed?: bigint;
}

