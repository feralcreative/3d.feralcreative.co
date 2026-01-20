/**
 * Patch server.js to use the new TCP session manager
 */

import { readFileSync, writeFileSync } from "fs";

const serverPath = "server.js";
let content = readFileSync(serverPath, "utf-8");

// 1. Add import after the Socket import
const socketImportLine = 'import { Socket } from "net";';
const newImport = 'import { sendGcodeSession } from "./utils/tcp-gcode-session.js";';

if (!content.includes(newImport)) {
  content = content.replace(socketImportLine, `${socketImportLine}\n${newImport}`);
  console.log("✓ Added import for sendGcodeSession");
}

// 2. Replace the filament change sequence
const oldSequence = `      console.log(\`[GCODE] Executing filament change sequence\`);

      try {
        // Step 1: Home all axes
        console.log(\`[GCODE] Step 1: Homing axes\`);
        await sendTcpCommand("G28");

        // Step 2: Move to center of bed (assuming 220x220 bed)
        // Try breaking movement into separate commands for each axis
        console.log(\`[GCODE] Step 2: Moving to center position\`);
        await sendTcpCommand("G90"); // Absolute positioning

        console.log(\`[GCODE] Step 2a: Moving X axis to 110\`);
        await sendTcpCommand("G1 X110 F9000");

        console.log(\`[GCODE] Step 2b: Moving Y axis to 110\`);
        await sendTcpCommand("G1 Y110 F9000");

        console.log(\`[GCODE] Step 2c: Moving Z axis to 100\`);
        await sendTcpCommand("G1 Z100 F9000");

        console.log(\`[GCODE] Filament change prep complete. Head is centered and ready.\`);

        return res.json({
          success: true,
          command,
          response: "Printer homed and moved to center position. Ready for filament change.",
          stage: "ready_for_filament_change",
        });
      } catch (error) {
        console.error(\`[GCODE] Filament change error:\`, error);
        return res.status(500).json({
          error: "Failed to execute filament change",
          details: error.message,
        });
      }`;

const newSequence = `      console.log(\`[GCODE] Executing filament change sequence\`);

      try {
        // Use session manager to send all commands in one control session
        const commands = [
          "G90",        // Absolute positioning
          "G28",        // Home all axes
          "G1 X110 Y110 Z100 F9000"  // Move to center position
        ];

        console.log(\`[GCODE] Sending \${commands.length} commands in single session\`);
        const result = await sendGcodeSession(PRINTER_IP, 8899, commands, true);

        if (!result.success) {
          throw new Error(result.error || "Failed to execute commands");
        }

        console.log(\`[GCODE] Filament change prep complete. Head is centered and ready.\`);

        return res.json({
          success: true,
          command,
          response: "Printer homed and moved to center position. Ready for filament change.",
          stage: "ready_for_filament_change",
          details: result.responses,
        });
      } catch (error) {
        console.error(\`[GCODE] Filament change error:\`, error);
        return res.status(500).json({
          error: "Failed to execute filament change",
          details: error.message,
        });
      }`;

if (content.includes(oldSequence)) {
  content = content.replace(oldSequence, newSequence);
  console.log("✓ Replaced filament change sequence");
} else {
  console.log("⚠ Could not find exact match for filament change sequence");
  console.log("  Manual update may be required");
}

// Write the updated content
writeFileSync(serverPath, content, "utf-8");
console.log("✓ server.js has been patched");
console.log("\nRestart the server to apply changes:");
console.log("  npm start");

