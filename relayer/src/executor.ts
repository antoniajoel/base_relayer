import { ethers } from "ethers";
import { Forwarder } from "./types";

/**
 * Executes forward requests on-chain
 */
export class Executor {
  private forwarder: ethers.Contract;
  private wallet: ethers.Wallet;
  private provider: ethers.Provider;

  constructor(
    forwarderAddress: string,
    privateKey: string,
    provider: ethers.Provider
  ) {
    this.provider = provider;
    this.wallet = new ethers.Wallet(privateKey, provider);
    
    // Forwarder ABI for execute function
    const forwarderABI = [
      "function execute((address from, address to, uint256 value, uint256 gas, uint256 nonce, bytes data), bytes signature) payable returns (bool success, bytes memory ret)"
    ];
    this.forwarder = new ethers.Contract(forwarderAddress, forwarderABI, this.wallet);
  }

  /**
   * Execute a forward request
   */
  async execute(req: Forwarder.ForwardRequest, signature: string): Promise<ethers.TransactionReceipt> {
    try {
      const tx = await this.forwarder.execute(req, signature, {
        value: req.value,
        gasLimit: req.gas,
      });

      const receipt = await tx.wait();
      return receipt!;
    } catch (error) {
      console.error("Error executing request:", error);
      throw error;
    }
  }

  /**
   * Get relayer address
   */
  getAddress(): string {
    return this.wallet.address;
  }

  /**
   * Get relayer balance
   */
  async getBalance(): Promise<bigint> {
    return await this.provider.getBalance(this.wallet.address);
  }
}

