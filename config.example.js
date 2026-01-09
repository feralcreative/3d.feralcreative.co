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
  STREAM_URL: {
    // Development: Local network access to your NAS
    DEV: "http://YOUR_NAS_IP:5000/webapi/entry.cgi?api=SYNO.SurveillanceStation.Stream.VideoStreaming&version=1&method=Stream&format=mjpeg&cameraId=YOUR_CAMERA_ID&StmKey=YOUR_STREAM_KEY",
    // Production: HTTPS via your NAS domain
    PROD: "https://nas.yourdomain.com/webapi/entry.cgi?api=SYNO.SurveillanceStation.Stream.VideoStreaming&version=1&method=Stream&format=mjpeg&cameraId=YOUR_CAMERA_ID&StmKey=YOUR_STREAM_KEY",
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

