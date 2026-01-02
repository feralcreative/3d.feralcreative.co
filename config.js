// Google OAuth Configuration
// Replace with your actual OAuth 2.0 Client ID from Google Cloud Console
const CONFIG = {
  // Development mode - set to true to bypass authentication (localhost only)
  DEV_MODE: true,

  // Get this from: https://console.cloud.google.com/apis/credentials
  // Create OAuth 2.0 Client ID > Web application
  // Add authorized JavaScript origins:
  //   - http://localhost:5501 (for local development)
  //   - https://3d.feralcreative.co (for production)
  GOOGLE_CLIENT_ID: "233064289536-85l4kha72ecka84gmf6f2d1bgkn3h16g.apps.googleusercontent.com",

  // Optional: Restrict to specific email addresses or domains
  // Leave empty array [] to allow any Google account
  // Examples:
  ALLOWED_EMAILS: [
    "ziadezzat@gmail.com",
    "rhobbs007@gmail.com",
    "@feralcreative.co",
    "ziadandrebecca@gmail.com",
    "dslavik@gmail.com",
    "brian.donnellan@gmail.com",
    "dylan.seidner@gmail.com",
    "dizzydezidee@gmail.com",
    "tess.evans@gmail.com",
    "tyler.phelps@gmail.com",
    "zmezzat@gmail.com",
    "daveablees@gmail.com",
    "ohbandit@gmail.com",
    "connormstock@gmail.com",
    "epdale@gmail.com",
    "@ziad.af",
  ],

  // Stream URL configuration
  STREAM_URL: {
    // Development: Local network access
    DEV: "http://192.168.86.5:5000/webapi/entry.cgi?api=SYNO.SurveillanceStation.Stream.VideoStreaming&version=1&method=Stream&format=mjpeg&cameraId=2&StmKey=665921b8f4c2aca18eadfc511624ef72",
    // Production: HTTPS via nas.feralcreative.co (already reverse proxied to DSM)
    PROD: "https://nas.feralcreative.co/webapi/entry.cgi?api=SYNO.SurveillanceStation.Stream.VideoStreaming&version=1&method=Stream&format=mjpeg&cameraId=2&StmKey=665921b8f4c2aca18eadfc511624ef72",
  },
};
