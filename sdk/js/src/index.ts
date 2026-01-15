import { ethers } from "ethers";

export interface ForwardRequest {
  from: string;
  to: string;
  value: bigint | string;
  gas: bigint | string;
  nonce: bigint | string;
  data: string;
}

export interface RelayOptions {
  apiUrl: string;
  chainId: number;
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

/**
 * BaseRelayer SDK
 */
export class BaseRelayer {
  private apiUrl: string;
  private chainId: number;

  constructor(options: RelayOptions) {
    this.apiUrl = options.apiUrl;
    this.chainId = options.chainId;
  }

  /**
   * Send a gasless transaction
   */
  async sendGaslessTx(request: {
    to: string;
    data: string;
    value?: bigint | string;
    gas?: bigint | string;
  }): Promise<RelayResponse> {
    // This is a placeholder - in production, you'd sign the request with the user's wallet
    // For now, return an error indicating signature is needed
    throw new Error("Signature required. Use sendGaslessTxWithSignature instead.");
  }

  /**
   * Send a gasless transaction with signature
   */
  async sendGaslessTxWithSignature(
    request: ForwardRequest,
    signature: string
  ): Promise<RelayResponse> {
    const response = await fetch(`${this.apiUrl}/relay`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        request: {
          ...request,
          value: request.value?.toString() || "0",
          gas: request.gas?.toString() || "100000",
          nonce: request.nonce?.toString() || "0",
        },
        signature,
      }),
    });

    return await response.json();
  }

  /**
   * Get transaction status
   */
  async getStatus(txHash: string): Promise<TransactionStatus> {
    const response = await fetch(`${this.apiUrl}/status/${txHash}`);
    return await response.json();
  }

  /**
   * Get rate limits
   */
  async getLimits(address: string): Promise<any> {
    const response = await fetch(`${this.apiUrl}/limits?address=${address}`);
    return await response.json();
  }

  /**
   * Get relayer statistics
   */
  async getStats(): Promise<any> {
    const response = await fetch(`${this.apiUrl}/stats`);
    return await response.json();
  }
}

