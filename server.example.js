/**
 * Development Proxy Server for FlashForge Printer API
 *
 * This server proxies requests from the browser to the printer,
 * solving CORS issues during local development.
 *
 * Setup:
 * 1. Copy this file: cp server.example.js server.js
 * 2. Make sure config.js exists with your printer credentials
 * 3. Run with: node server.js
 */

import express from "express";
import cors from "cors";
import { readFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load configuration from config.js
let CONFIG;
try {
  const configContent = readFileSync(join(__dirname, "config.js"), "utf-8");
  // Extract CONFIG object from the file
  const configMatch = configContent.match(/const CONFIG = ({[\s\S]*?});/);
  if (configMatch) {
    CONFIG = eval(`(${configMatch[1]})`);
  } else {
    throw new Error("Could not parse CONFIG from config.js");
  }
} catch (error) {
  console.error("❌ Error loading config.js:", error.message);
  console.error("Make sure config.js exists and has the correct format.");
  console.error("\nTo set up:");
  console.error("  1. Copy config.example.js to config.js");
  console.error("  2. Edit config.js with your printer credentials");
  process.exit(1);
}

const app = express();
const PORT = 3001;

// Printer configuration from config.js
const PRINTER_IP = CONFIG.PRINTER.IP;
const PRINTER_PORT = 8898;
const PRINTER_SERIAL = CONFIG.PRINTER.SERIAL;
const PRINTER_CHECK_CODE = CONFIG.PRINTER.CHECK_CODE;

// Enable CORS for local development
app.use(cors());
app.use(express.json());

// Proxy endpoint for /product
app.post("/product", async (req, res) => {
  try {
    const response = await fetch(`http://${PRINTER_IP}:${PRINTER_PORT}/product`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        serialNumber: PRINTER_SERIAL,
        checkCode: PRINTER_CHECK_CODE,
      }),
    });

    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error("Error proxying /product:", error);
    res.status(500).json({ error: "Failed to connect to printer", details: error.message });
  }
});

// Proxy endpoint for /detail
app.post("/detail", async (req, res) => {
  try {
    const response = await fetch(`http://${PRINTER_IP}:${PRINTER_PORT}/detail`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        serialNumber: PRINTER_SERIAL,
        checkCode: PRINTER_CHECK_CODE,
      }),
    });

    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error("Error proxying /detail:", error);
    res.status(500).json({ error: "Failed to connect to printer", details: error.message });
  }
});

// Proxy endpoint for /control
app.post("/control", async (req, res) => {
  try {
    const response = await fetch(`http://${PRINTER_IP}:${PRINTER_PORT}/control`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        serialNumber: PRINTER_SERIAL,
        checkCode: PRINTER_CHECK_CODE,
        ...req.body, // Include control commands from client
      }),
    });

    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error("Error proxying /control:", error);
    res.status(500).json({ error: "Failed to connect to printer", details: error.message });
  }
});

// Proxy endpoint for /job
app.get("/job", async (req, res) => {
  try {
    const response = await fetch(`http://${PRINTER_IP}:${PRINTER_PORT}/job`, {
      method: "GET",
      headers: {
        SN: PRINTER_SERIAL,
        CHKCODE: PRINTER_CHECK_CODE,
      },
    });

    const text = await response.text();

    // Handle empty response (no active job)
    if (!text || text.trim() === "") {
      res.json({ code: 0, message: "No active job", job: null });
      return;
    }

    try {
      const data = JSON.parse(text);
      res.json(data);
    } catch (parseError) {
      // If JSON parsing fails, return empty job
      res.json({ code: 0, message: "No active job", job: null });
    }
  } catch (error) {
    console.error("Error proxying job request:", error);
    res.status(500).json({ error: "Failed to get job info", details: error.message });
  }
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ status: "ok", printer: `${PRINTER_IP}:${PRINTER_PORT}` });
});

app.listen(PORT, () => {
  console.log(`\n🚀 Development proxy server running on http://localhost:${PORT}`);
  console.log(`📡 Proxying to printer at ${PRINTER_IP}:${PRINTER_PORT}`);
  console.log(`\nAvailable endpoints:`);
  console.log(`  POST http://localhost:${PORT}/product`);
  console.log(`  POST http://localhost:${PORT}/detail`);
  console.log(`  POST http://localhost:${PORT}/control`);
  console.log(`  GET  http://localhost:${PORT}/health\n`);
});
