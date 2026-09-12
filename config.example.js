// Google OAuth Configuration
// Replace with your actual OAuth 2.0 Client ID from Google Cloud Console
const CONFIG = {
  // Development mode - set to true to bypass authentication (localhost only)
  DEV_MODE: true,

  // Get this from: https://console.cloud.google.com/apis/credentials
  // Create OAuth 2.0 Client ID > Web application
  // Add authorized JavaScript origins:
  //   - http://localhost:5501 (for local development)
  //   - https://yourdomain.com (for production)
  GOOGLE_CLIENT_ID: "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com",

  // Optional: Restrict to specific email addresses or domains
  // Leave empty array [] to allow any Google account
  // Examples:
  //   - "user@example.com" - specific email
  //   - "@yourdomain.com" - any email from this domain
  ALLOWED_EMAILS: [
    "@yourdomain.com",
    "user1@example.com",
    "user2@example.com",
  ],

  // Stream URL configuration
  // Both point at the local proxy rather than at the NAS directly. Browsers will
  // not render an MJPEG feed in an <img> over HTTP/2, and proxying keeps the
  // Surveillance Station StmKey out of this file, which is served to the browser.
  // Set the real feed URL as CAMERA_STREAM_URL in printer-proxy-server.js.
  STREAM_URL: {
    // Development: Direct connection to local proxy server
    DEV: "http://localhost:3001/stream",
    // Production: Reverse proxied through domain (handled by nginx/reverse proxy)
    PROD: "/api/stream",
  },

  // FlashForge Printer Configuration
  // Replace these with your actual printer details
  PRINTER: {
    // Printer IP address on local network
    IP: "192.168.1.XXX", // Update with your printer's IP
    // Serial number (found on printer or in FlashPrint)
    SERIAL: "YOUR_PRINTER_SERIAL_NUMBER",
    // Check code (found in printer settings)
    CHECK_CODE: "YOUR_PRINTER_CHECK_CODE",
    // Update interval in milliseconds (how often to fetch printer status)
    UPDATE_INTERVAL: 5000, // 5 seconds

    // Current filament/material configuration
    // Update this when you change filament
    FILAMENT: {
      COLOR: "Black", // Current filament color
    },

    // Current project information
    // Update this when you start a new print job
    CURRENT_PROJECT: {
      NAME: "Your Project Name",
      URL: "https://www.printables.com/model/YOUR_MODEL_ID",
    },
  },
};

