# Project Status - Filament Change Feature

**Date:** 2026-01-16  
**Status:** In Progress - Server Integration

## What We're Working On

Adding a "Prep for Filament Change" button to the hamburger menu that sends G-code commands to pause the printer and prepare for a filament change.

## What's Been Completed

1. ✅ Created UI button in hamburger menu (`auth.js`)

   - Button shows for users with `ADVANCED_FEATURES` permission
   - Styled with printer icon and proper hover states
   - Located in the hamburger menu after sign-out button

2. ✅ Created frontend handler (`filament-change.js`)

   - Sends G-code command `M600` to printer
   - Uses `/gcode` endpoint on proxy server
   - Includes user email for permission checking
   - Shows success/error notifications

3. ✅ Added `/gcode` endpoint to `server.js`

   - Accepts POST requests with `{ command, userEmail }` body
   - Checks `ADVANCED_FEATURES` permission
   - Sends commands via TCP on port 8899
   - Includes helper function `sendTcpCommand()` for TCP communication
   - Added `hasAdvancedFeatures()` permission check function

4. ✅ Updated configuration
   - Changed `PRINTER_PROXY_URL.DEV` from `http://localhost:6199` to `http://localhost:3001` in `config.js`
   - This ensures frontend uses the main proxy server (not the separate printer-proxy-server)

## Current Issue

**Server won't start** - The `npm start` command is failing, likely due to:

- Missing `ADVANCED_FEATURES` in `config.js`
- Possible syntax error in recent changes
- Process conflicts on ports 3001 or 5501

## What Needs to Happen Next

1. **Fix the server startup issue:**

   - Check terminal output from `npm start` for error messages
   - Verify `config.js` has `ADVANCED_FEATURES` array defined
   - Kill any processes on ports 3001 and 5501: `lsof -ti:3001 | xargs kill -9` and `lsof -ti:5501 | xargs kill -9`
   - Try running `node server.js` directly to see specific error

2. **Add missing config (if needed):**

   - Add to `config.js` in the CONFIG object:

     ```javascript
     ADVANCED_FEATURES: ["your-email@example.com"],
     ```

3. **Test the feature:**
   - Run `npm start` successfully
   - Open `http://localhost:5501` in browser
   - Sign in with an email in `ADVANCED_FEATURES`
   - Open hamburger menu
   - Click "Prep for Filament Change" button
   - Verify G-code command is sent to printer

## Files Modified

- `auth.js` - Added filament change button to hamburger menu
- `filament-change.js` - NEW FILE - Handler for filament change feature
- `server.js` - Added `/gcode` endpoint, `hasAdvancedFeatures()` function, `sendTcpCommand()` helper
- `config.js` - Changed `PRINTER_PROXY_URL.DEV` to port 3001
- `package.json` - No changes needed (already uses `node server.js`)

## Key Technical Details

- **G-code Command:** `M600` (standard filament change command)
- **TCP Port:** 8899 (for direct G-code commands to FlashForge printer)
- **HTTP Port:** 3001 (main proxy server with all endpoints)
- **Vite Dev Port:** 5501
- **Permission Check:** Uses `ADVANCED_FEATURES` array from config
- **Command Format:** FlashForge expects commands prefixed with `~` and ending with `\r\n`

## Notes

- The separate `printer-proxy-server.js` file (port 6199) is NOT being used
- All functionality is consolidated in `server.js` (port 3001)
- The `/gcode` endpoint is now available alongside `/product`, `/detail`, `/control`, `/upload`
