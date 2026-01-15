import { ethers } from "ethers";
import { Forwarder } from "./types";

/**
 * Validates forward requests and signatures
 */
export class Validator {
  private forwarder: ethers.Contract;
  private provider: ethers.Provider;

  constructor(forwarderAddress: string, provider: ethers.Provider) {
    this.provider = provider;
    // Forwarder ABI (minimal for verify function)
    const forwarderABI = [
      "function verify((address from, address to, uint256 value, uint256 gas, uint256 nonce, bytes data), bytes signature) view returns (bool)",
      "function getNonce(address from) view returns (uint256)"
    ];
    this.forwarder = new ethers.Contract(forwarderAddress, forwarderABI, provider);
  }

  /**
   * Verify a forward request signature
   */
  async verifyRequest(req: Forwarder.ForwardRequest, signature: string): Promise<boolean> {
    try {
      return await this.forwarder.verify(req, signature);
    } catch (error) {
      console.error("Error verifying request:", error);
      return false;
    }
  }

  /**
   * Get nonce for an address
   */
  async getNonce(address: string): Promise<bigint> {
    try {
      return await this.forwarder.getNonce(address);
    } catch (error) {
      console.error("Error getting nonce:", error);
      throw error;
    }
  }

  /**
   * Validate request structure
   */
  validateRequest(req: Forwarder.ForwardRequest): { valid: boolean; error?: string } {
    if (!ethers.isAddress(req.from)) {
      return { valid: false, error: "Invalid from address" };
    }
    if (!ethers.isAddress(req.to)) {
      return { valid: false, error: "Invalid to address" };
    }
    if (req.gas === 0n) {
      return { valid: false, error: "Gas must be greater than 0" };
    }
    return { valid: true };
  }
}

