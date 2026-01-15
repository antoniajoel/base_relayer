import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { ethers } from "ethers";
import { Validator } from "./validator";
import { Executor } from "./executor";
import { RelayRequest, RelayResponse, TransactionStatus } from "./types";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Configuration
const PORT = process.env.PORT || 3002;
const FORWARDER_ADDRESS = process.env.FORWARDER_ADDRESS || "";
const RELAYER_PRIVATE_KEY = process.env.RELAYER_PRIVATE_KEY || "";
const RPC_URL = process.env.RPC_URL || "https://sepolia.base.org";

// Initialize provider
const provider = new ethers.JsonRpcProvider(RPC_URL);

// Initialize validator and executor
const validator = new Validator(FORWARDER_ADDRESS, provider);
const executor = new Executor(FORWARDER_ADDRESS, RELAYER_PRIVATE_KEY, provider);

// Transaction tracking
const transactions = new Map<string, TransactionStatus>();

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "ok", chainId: provider.network?.chainId });
});

// Relay endpoint
app.post("/relay", async (req, res) => {
  try {
    const relayReq: RelayRequest = req.body;

    // Validate request structure
    const validation = validator.validateRequest(relayReq.request);
    if (!validation.valid) {
      return res.status(400).json({
        success: false,
        error: validation.error,
      } as RelayResponse);
    }

    // Verify signature
    const isValid = await validator.verifyRequest(relayReq.request, relayReq.signature);
    if (!isValid) {
      return res.status(400).json({
        success: false,
        error: "Invalid signature",
      } as RelayResponse);
    }

    // Execute transaction
    const receipt = await executor.execute(relayReq.request, relayReq.signature);

    // Track transaction
    transactions.set(receipt.hash, {
      hash: receipt.hash,
      status: receipt.status === 1 ? "confirmed" : "failed",
      blockNumber: receipt.blockNumber,
      gasUsed: receipt.gasUsed,
    });

    res.json({
      success: true,
      txHash: receipt.hash,
    } as RelayResponse);
  } catch (error: any) {
    console.error("Relay error:", error);
    res.status(500).json({
      success: false,
      error: error.message || "Internal server error",
    } as RelayResponse);
  }
});

// Transaction status endpoint
app.get("/status/:txHash", async (req, res) => {
  try {
    const { txHash } = req.params;

    // Check tracked transactions
    if (transactions.has(txHash)) {
      return res.json(transactions.get(txHash));
    }

    // Query on-chain
    const receipt = await provider.getTransactionReceipt(txHash);
    if (!receipt) {
      return res.status(404).json({
        hash: txHash,
        status: "pending",
      } as TransactionStatus);
    }

    const status: TransactionStatus = {
      hash: txHash,
      status: receipt.status === 1 ? "confirmed" : "failed",
      blockNumber: receipt.blockNumber,
      gasUsed: receipt.gasUsed,
    };

    res.json(status);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Relayer info endpoint
app.get("/info", async (req, res) => {
  try {
    const address = executor.getAddress();
    const balance = await executor.getBalance();

    res.json({
      address,
      balance: balance.toString(),
      chainId: (await provider.getNetwork()).chainId,
      forwarder: FORWARDER_ADDRESS,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 BaseRelayer server running on port ${PORT}`);
  console.log(`📍 Forwarder: ${FORWARDER_ADDRESS}`);
  console.log(`🔗 RPC: ${RPC_URL}`);
  console.log(`💼 Relayer: ${executor.getAddress()}`);
});

