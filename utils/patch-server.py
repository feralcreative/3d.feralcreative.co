#!/usr/bin/env python3
"""
Patch server.js to use the new TCP session manager
"""

# Read the file
with open("server.js", "r") as f:
    content = f.read()

# 1. Add import after the Socket import
socket_import = 'import { Socket } from "net";'
new_import = 'import { sendGcodeSession } from "./utils/tcp-gcode-session.js";'

if new_import not in content:
    content = content.replace(socket_import, f'{socket_import}\n{new_import}')
    print("✓ Added import for sendGcodeSession")

# 2. Replace the filament change sequence
old_sequence = '''      console.log(`[GCODE] Executing filament change sequence`);

      try {
        // Step 1: Home all axes
        console.log(`[GCODE] Step 1: Homing axes`);
        await sendTcpCommand("G28");

        // Step 2: Move to center of bed (assuming 220x220 bed)
        // Try breaking movement into separate commands for each axis
        console.log(`[GCODE] Step 2: Moving to center position`);
        await sendTcpCommand("G90"); // Absolute positioning

        console.log(`[GCODE] Step 2a: Moving X axis to 110`);
        await sendTcpCommand("G1 X110 F9000");

        console.log(`[GCODE] Step 2b: Moving Y axis to 110`);
        await sendTcpCommand("G1 Y110 F9000");

        console.log(`[GCODE] Step 2c: Moving Z axis to 100`);
        await sendTcpCommand("G1 Z100 F9000");

        console.log(`[GCODE] Filament change prep complete. Head is centered and ready.`);

        return res.json({
          success: true,
          command,
          response: "Printer homed and moved to center position. Ready for filament change.",
          stage: "ready_for_filament_change",
        });
      } catch (error) {
        console.error(`[GCODE] Filament change error:`, error);
        return res.status(500).json({
          error: "Failed to execute filament change",
          details: error.message,
        });
      }'''

new_sequence = '''      console.log(`[GCODE] Executing filament change sequence`);

      try {
        // Use session manager to send all commands in one control session
        const commands = [
          "G90",        // Absolute positioning
          "G28",        // Home all axes
          "G1 X110 Y110 Z100 F9000"  // Move to center position
        ];

        console.log(`[GCODE] Sending ${commands.length} commands in single session`);
        const result = await sendGcodeSession(PRINTER_IP, 8899, commands, true);

        if (!result.success) {
          throw new Error(result.error || "Failed to execute commands");
        }

        console.log(`[GCODE] Filament change prep complete. Head is centered and ready.`);

        return res.json({
          success: true,
          command,
          response: "Printer homed and moved to center position. Ready for filament change.",
          stage: "ready_for_filament_change",
          details: result.responses,
        });
      } catch (error) {
        console.error(`[GCODE] Filament change error:`, error);
        return res.status(500).json({
          error: "Failed to execute filament change",
          details: error.message,
        });
      }'''

if old_sequence in content:
    content = content.replace(old_sequence, new_sequence)
    print("✓ Replaced filament change sequence")
else:
    print("⚠ Could not find exact match for filament change sequence")

# Write the updated content
with open("server.js", "w") as f:
    f.write(content)

print("✓ server.js has been patched")
print("\nRestart the server to apply changes:")
print("  npm start")

