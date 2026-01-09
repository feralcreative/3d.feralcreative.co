/**
 * Printer API Proxy Server
 * 
 * This Node.js server proxies requests to the FlashForge printer,
 * solving CORS and network isolation issues.
 */

import express from "express";
import cors from "cors";

const app = express();
const PORT = process.env.PRINTER_PROXY_PORT || 6199;

// Printer configuration - REPLACE WITH YOUR VALUES
const PRINTER_IP = "192.168.1.XXX"; // Your printer's IP address
const PRINTER_SERIAL = "YOUR_PRINTER_SERIAL_NUMBER"; // Your printer's serial number
const PRINTER_CHECK_CODE = "YOUR_PRINTER_CHECK_CODE"; // Your printer's check code

// Enable CORS - UPDATE WITH YOUR DOMAINS
app.use(
  cors({
    origin: [
      "https://yourdomain.com", // Your production domain
      "http://localhost:5501", // Local development
      "http://localhost:3000", // Alternative local port
    ],
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type", "SN", "CHKCODE"],
  })
);

app.use(express.json());

// Proxy endpoint - extracts endpoint from URL path
app.all("*", async (req, res) => {
  try {
    // Extract endpoint from URL path (e.g., /product, /detail, /job)
    const pathEndpoint = req.path.substring(1); // Remove leading slash
    const endpoint = pathEndpoint || "product"; // Default to 'product'

    console.log(`[PROXY] Request path: ${req.path}, endpoint: ${endpoint}`);

    // Validate endpoint
    const allowedEndpoints = ["product", "detail", "job"];
    if (!allowedEndpoints.includes(endpoint)) {
      console.log(`[PROXY] Invalid endpoint: ${endpoint}`);
      return res.status(400).json({ error: "Invalid endpoint" });
    }

    // Build printer URL
    const printerUrl = `http://${PRINTER_IP}:8898/${endpoint}`;
    console.log(`[PROXY] Forwarding to: ${printerUrl}`);

    // Prepare request options
    const options = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
    };

    // Prepare request body for POST endpoints
    let body = null;
    if (["product", "detail"].includes(endpoint)) {
      body = JSON.stringify({
        serialNumber: PRINTER_SERIAL,
        checkCode: PRINTER_CHECK_CODE,
      });
      console.log(`[PROXY] Using POST with body`);
    } else {
      // For GET endpoints (job), use headers
      options.headers["SN"] = PRINTER_SERIAL;
      options.headers["CHKCODE"] = PRINTER_CHECK_CODE;
      options.method = "GET";
      console.log(`[PROXY] Using GET with headers`);
    }

    if (body) {
      options.body = body;
    }

    // Make request to printer
    console.log(`[PROXY] Sending request...`);
    const response = await fetch(printerUrl, options);
    const data = await response.text();

    console.log(`[PROXY] Response status: ${response.status}`);
    console.log(`[PROXY] Response data length: ${data.length} bytes`);

    // Try to parse as JSON
    try {
      const jsonData = JSON.parse(data);
      console.log(`[PROXY] Returning JSON response`);
      res.json(jsonData);
    } catch (e) {
      // If not JSON, return as text
      console.log(`[PROXY] Returning text response`);
      res.send(data);
    }
  } catch (error) {
    console.error("[PROXY] Error:", error);
    res.status(500).json({
      error: "Failed to connect to printer",
      details: error.message,
    });
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`[PROXY] Printer proxy server running on port ${PORT}`);
  console.log(`[PROXY] Proxying requests to printer at ${PRINTER_IP}:8898`);
  console.log(`[PROXY] Allowed endpoints: product, detail, job`);
});

