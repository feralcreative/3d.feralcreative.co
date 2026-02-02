/**
 * TCP G-code Session Manager
 * Maintains a single control session for sending multiple G-code commands
 */

import net from "net";

/**
 * Send multiple G-code commands in a single control session
 * @param {string} printerIp - Printer IP address
 * @param {number} printerPort - TCP port (usually 8899)
 * @param {string[]} commands - Array of G-code commands to send (without ~ prefix)
 * @param {boolean} verbose - Enable verbose logging
 * @returns {Promise<{success: boolean, responses: string[], error?: string}>}
 */
export async function sendGcodeSession(printerIp, printerPort, commands, verbose = true) {
  return new Promise((resolve) => {
    const client = new net.Socket();
    const responses = [];
    let buffer = "";
    let currentCommandIndex = -1; // -1 = login, 0+ = commands array index
    let isLoggedIn = false;
    let isWaitingForResponse = false;
    let responseTimeout = null;

    const COMMAND_TIMEOUT = 30000; // 30 seconds per command
    const LOGIN_CMD = "~M601 S1\r\n";
    const LOGOUT_CMD = "~M602\r\n";

    function log(message) {
      if (verbose) {
        console.log(`[TCP SESSION] ${message}`);
      }
    }

    function cleanup(success, error = null) {
      if (responseTimeout) {
        clearTimeout(responseTimeout);
      }
      client.destroy();

      if (success) {
        resolve({ success: true, responses });
      } else {
        resolve({ success: false, responses, error });
      }
    }

    function sendNextCommand() {
      if (currentCommandIndex >= commands.length) {
        // All commands sent, logout and close immediately
        log("All commands sent, logging out...");
        client.write(LOGOUT_CMD);

        // Give the printer a moment to process logout, then close
        setTimeout(() => {
          log("Closing connection");
          cleanup(true);
        }, 100);
        return;
      }

      const command = commands[currentCommandIndex];
      const formattedCommand = `~${command}\r\n`;

      log(`Sending command ${currentCommandIndex + 1}/${commands.length}: ${command}`);
      isWaitingForResponse = true;
      client.write(formattedCommand);

      responseTimeout = setTimeout(() => {
        log(`Command timeout: ${command}`);
        cleanup(false, `Timeout waiting for response to: ${command}`);
      }, COMMAND_TIMEOUT);
    }

    function processResponse(data) {
      const text = data.trim();

      if (!text) return;

      log(`Received: ${text}`);

      // Check for login response
      if (!isLoggedIn && text.includes("Control Success")) {
        log("✓ Login successful");
        isLoggedIn = true;
        isWaitingForResponse = false;
        if (responseTimeout) clearTimeout(responseTimeout);

        // Start sending commands
        currentCommandIndex = 0;
        sendNextCommand();
        return;
      }

      // Check for logout response
      if (text.includes("Control Release")) {
        log("✓ Logout successful");
        if (responseTimeout) clearTimeout(responseTimeout);
        cleanup(true);
        return;
      }

      // Check for command acknowledgment
      if (isWaitingForResponse && currentCommandIndex >= 0) {
        if (text.includes("ok") || text.includes("Received")) {
          responses.push(text);
          log(`✓ Command ${currentCommandIndex + 1} acknowledged`);
          isWaitingForResponse = false;
          if (responseTimeout) clearTimeout(responseTimeout);

          // Wait a moment for the printer to actually execute the command
          // before sending the next one
          setTimeout(() => {
            currentCommandIndex++;
            sendNextCommand();
          }, 500); // 500ms delay between commands
        }
      }

      // Check for errors
      if (text.includes("failed") || text.includes("error")) {
        log(`✗ Error response: ${text}`);
        cleanup(false, `Printer error: ${text}`);
      }
    }

    // Connect to printer
    client.connect(printerPort, printerIp, () => {
      log(`Connected to ${printerIp}:${printerPort}`);
      log("Sending login command...");
      client.write(LOGIN_CMD);

      responseTimeout = setTimeout(() => {
        log("Login timeout");
        cleanup(false, "Login timeout");
      }, 5000);
    });

    // Handle incoming data
    client.on("data", (data) => {
      buffer += data.toString();

      // Process complete lines
      const lines = buffer.split("\n");
      buffer = lines.pop() || ""; // Keep incomplete line in buffer

      lines.forEach((line) => {
        processResponse(line);
      });
    });

    // Handle connection errors
    client.on("error", (err) => {
      log(`Connection error: ${err.message}`);
      cleanup(false, err.message);
    });

    // Handle connection close
    client.on("close", () => {
      log("Connection closed");
      if (isLoggedIn && currentCommandIndex >= commands.length) {
        cleanup(true);
      }
    });
  });
}
