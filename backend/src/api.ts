import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { ethers } from "ethers";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3001;
const RELAYER_URL = process.env.RELAYER_URL || "http://localhost:3002";
const FORWARDER_ADDRESS = process.env.FORWARDER_ADDRESS || "";
const RELAYER_HUB_ADDRESS = process.env.RELAYER_HUB_ADDRESS || "";
const RPC_URL = process.env.RPC_URL || "https://sepolia.base.org";

const provider = new ethers.JsonRpcProvider(RPC_URL);

// Health check
app.get("/health", async (req, res) => {
  const network = await provider.getNetwork();
  res.json({ status: "ok", chainId: network.chainId });
});

// Relay endpoint - proxies to relayer
app.post("/relay", async (req, res) => {
  try {
    const response = await fetch(`${RELAYER_URL}/relay`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(req.body),
    });

    const data = await response.json();
    res.status(response.status).json(data);
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Transaction status
app.get("/status/:txHash", async (req, res) => {
  try {
    const { txHash } = req.params;
    const response = await fetch(`${RELAYER_URL}/status/${txHash}`);
    const data = await response.json();
    res.json(data);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get rate limits
app.get("/limits", async (req, res) => {
  try {
    const { address } = req.query;
    if (!address || !RELAYER_HUB_ADDRESS) {
      return res.json({
        userDailyLimit: 10,
        defaultDailyLimit: 100,
      });
    }

    // Query RelayerHub for limits
    const hubABI = [
      "function getUserUsage(address user) view returns ((address user, uint256 count, uint256 lastReset))",
      "function getSponsor(address sponsor) view returns ((address sponsor, uint256 dailyLimit, uint256 dailyUsed, uint256 lastReset, bool active))"
    ];
    const hub = new ethers.Contract(RELAYER_HUB_ADDRESS, hubABI, provider);

    const usage = await hub.getUserUsage(address as string);
    res.json({
      userDailyLimit: 10,
      userUsed: usage.count.toString(),
      defaultDailyLimit: 100,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get statistics
app.get("/stats", async (req, res) => {
  try {
    const relayerInfo = await fetch(`${RELAYER_URL}/info`).then((r) => r.json());
    
    res.json({
      relayer: relayerInfo,
      forwarder: FORWARDER_ADDRESS,
      hub: RELAYER_HUB_ADDRESS,
      chainId: (await provider.getNetwork()).chainId.toString(),
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`🌐 BaseRelayer API running on port ${PORT}`);
  console.log(`🔗 Relayer URL: ${RELAYER_URL}`);
});

