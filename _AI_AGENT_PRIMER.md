# AI Agent Primer: 3D Printer Stream

**Project:** Feral Creative 3D Printer Live Stream
**Domain:** https://3d.feralcreative.co
**Repository:** https://github.com/feralcreative/3d.feralcreative.co.git
**Last Updated:** 2026-01-05

---

## 🔒 SECRETS REFERENCE GUIDE

### 1. Google OAuth Credentials

**Location:** `.secrets/client_secret_233064289536-85l4kha72ecka84gmf6f2d1bgkn3h16g.apps.googleusercontent.com.json`

- `client_id` → `2330...h16g.apps.googleusercontent.com` (full ID in config.js)
- `client_secret` → `GOCSPX-q0b...wMss` (32 chars)
- `project_id` → `d-feralcreative-co`

**Also in:** `config.js` (line 12) - Client ID only (public, safe to commit)

### 2. Synology NAS Stream Key

**Location:** `config.js` (lines 41, 43)

- Stream Key: `6659...ef72` (32 hex chars)
- Used in both DEV and PROD stream URLs

### 3. SFTP Deployment Credentials

**Location:** `.vscode/sftp.json`

- Host: `nas.feralcreative.co`
- Port: `337**` (5 digits)
- Username: `ziad`
- Auth: SSH agent (`$SSH_AUTH_SOCK`)
- Remote Path: `/web/3d.feralcreative.co`

### 4. Allowed Email Addresses

**Location:** `config.js` (lines 17-36)

- List of 15+ authorized email addresses
- Includes individual emails and domain wildcards (`@feralcreative.co`, `@ziad.af`)

### 🔐 Security Notes

- `.secrets/` directory is in `.gitignore` (line 237)
- Client ID is public and safe to commit
- Client Secret should NEVER be committed
- SFTP config is in `.gitignore` via `.vscode/` exclusion
- Stream key is embedded in URLs (consider rotating if exposed)

---

## 📁 PROJECT STRUCTURE

```text
3d.feralcreative.co/
├── .augment/                    # Symlink to shared Augment rules
├── .git/                        # Git repository
├── .secrets/                    # OAuth credentials (GITIGNORED)
│   └── client_secret_*.json     # Google OAuth client secret
├── .vscode/                     # VS Code configuration
│   ├── settings.json            # Live Server + Live Sass Compile config
│   └── sftp.json                # SFTP deployment config (GITIGNORED)
├── _archive/                    # Archived files (GITIGNORED)
├── _TASKS/                      # Task tracking (empty, GITIGNORED)
├── data/                        # Data directory (empty)
├── docs/                        # Documentation
│   └── GOOGLE_AUTH_SETUP.md     # OAuth setup instructions
├── images/                      # Static assets
│   ├── favicon.*                # Favicon files (multiple formats)
│   ├── feral-*.svg/png          # Branding assets
│   ├── offline.jpg              # Fallback image when stream is down
│   └── web-app-manifest-*.png   # PWA icons
├── styles/
│   ├── css/                     # Compiled CSS (GITIGNORED)
│   │   ├── main.css             # Auto-generated from SCSS
│   │   ├── main.min.css         # Minified version
│   │   └── main.css.map         # Source map
│   └── scss/                    # Source SCSS files
│       ├── _mixins.scss         # Responsive breakpoint mixins
│       ├── _variables.scss      # Color and font variables
│       └── main.scss            # Main stylesheet (entry point)
├── .gitignore                   # Git ignore rules
├── _AI_AGENT_PRIMER.md          # This file
├── _NOTES.md                    # Development notes (minimal)
├── auth.js                      # Google OAuth authentication logic
├── config.js                    # Configuration (OAuth, stream URLs, emails)
├── CONSOLE.txt                  # Empty console log file
├── favicon.ico                  # Root favicon
├── index.html                   # Main HTML file (SPA)
├── README.md                    # Empty readme
└── site.webmanifest             # PWA manifest
```

---

## 🎯 PROJECT OVERVIEW

### What This Is

A **single-page web application** that streams live video from a FlashForge Adventurer 5M Pro 3D printer. The stream is protected by Google OAuth authentication with email whitelisting.

### Key Features

1. **Google OAuth Authentication** - Users must sign in with authorized Google accounts
2. **Email Whitelisting** - Only specific emails/domains can access the stream
3. **Dev Mode Bypass** - Authentication skipped on localhost when `DEV_MODE: true`
4. **MJPEG Stream** - Live video from Synology Surveillance Station
5. **Offline Fallback** - Shows `offline.jpg` if stream is unavailable
6. **Hamburger Menu** - User info, printer details, sign-out button
7. **Responsive Design** - Works on desktop and mobile

### Technology Stack

- **Frontend:** Vanilla JavaScript (ES6+), HTML5, CSS3
- **Styling:** SCSS → CSS (compiled via Live Sass Compile)
- **Authentication:** Google Sign-In API (OAuth 2.0)
- **Video Stream:** MJPEG from Synology NAS
- **Development Server:** Live Server (VS Code extension, port 5501)
- **Deployment:** SFTP to Synology NAS
- **Version Control:** Git + GitHub

---

## 🚀 QUICK START (5-MINUTE SETUP)

### Prerequisites

- VS Code with extensions:
  - **Live Server** (ritwickdey.LiveServer)
  - **Live Sass Compile** (glenn2223.live-sass)
  - **SFTP** (Natizyskunk.sftp) - optional, for deployment
- Git
- SSH access to `nas.feralcreative.co` (for deployment only)

### Setup Steps

1. **Clone the repository:**

   ```bash
   git clone https://github.com/feralcreative/3d.feralcreative.co.git
   cd 3d.feralcreative.co
   ```

2. **Open in VS Code:**

   ```bash
   code .
   ```

3. **Start Live Sass Compile:**

   - VS Code will auto-compile SCSS on save (configured in `.vscode/settings.json`)
   - Look for "Watching..." in the status bar

4. **Start Live Server:**

   - Right-click `index.html` → "Open with Live Server"
   - Or click "Go Live" in VS Code status bar
   - Opens at `http://localhost:5501`

5. **Test the app:**
   - Should see login screen (or auto-login if `DEV_MODE: true`)
   - Sign in with an authorized Google account
   - Stream should load (or show offline image)

### Development Workflow

1. Edit SCSS files in `styles/scss/`
2. Live Sass Compile auto-generates CSS in `styles/css/`
3. Live Server auto-refreshes browser
4. Test authentication and stream functionality
5. Commit changes to Git
6. Deploy via SFTP (see Deployment section)

---

## 🏗️ ARCHITECTURE

### Application Flow

```text
┌─────────────────────────────────────────────────────────────┐
│                      index.html Loads                        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Load Google Sign-In API + config.js + auth.js              │
└─────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │  DEV_MODE Check │
                    └─────────────────┘
                     ↙              ↘
          YES (localhost)        NO (production)
                ↓                      ↓
    ┌──────────────────┐    ┌──────────────────────┐
    │ Auto-login as    │    │ Check sessionStorage │
    │ dev@localhost    │    │ for existing session │
    └──────────────────┘    └──────────────────────┘
                ↓                      ↓
                └──────────┬───────────┘
                           ↓
                  ┌─────────────────┐
                  │ User Signed In? │
                  └─────────────────┘
                   ↙              ↘
              NO                  YES
               ↓                   ↓
    ┌──────────────────┐    ┌──────────────────┐
    │ Show Login Screen│    │ Check Email      │
    │ with Google Btn  │    │ Whitelist        │
    └──────────────────┘    └──────────────────┘
               ↓                   ↓
    ┌──────────────────┐    ┌──────────────────┐
    │ User Clicks      │    │ Email Allowed?   │
    │ "Sign in with    │    └──────────────────┘
    │  Google"         │         ↙          ↘
    └──────────────────┘    YES              NO
               ↓              ↓                ↓
    ┌──────────────────┐    │         ┌──────────────┐
    │ Google OAuth     │    │         │ Show Error   │
    │ Popup            │    │         │ "Access      │
    └──────────────────┘    │         │  Denied"     │
               ↓              │         └──────────────┘
    ┌──────────────────┐    │
    │ Parse JWT Token  │    │
    └──────────────────┘    │
               ↓              │
               └──────────────┘
                      ↓
           ┌──────────────────────┐
           │ Hide Login Screen    │
           │ Show Stream Container│
           │ Show Hamburger Menu  │
           └──────────────────────┘
                      ↓
           ┌──────────────────────┐
           │ Load Stream URL      │
           │ (DEV or PROD)        │
           └──────────────────────┘
                      ↓
              ┌──────────────┐
              │ Stream Loads │
              └──────────────┘
                ↙          ↘
           SUCCESS        ERROR
              ↓              ↓
    ┌──────────────┐  ┌──────────────┐
    │ Show MJPEG   │  │ Show         │
    │ Stream       │  │ offline.jpg  │
    └──────────────┘  └──────────────┘
```

### Data Flow

1. **Configuration** (`config.js`) → Loaded globally as `CONFIG` object
2. **Authentication** (`auth.js`) → `GoogleAuth` class manages state
3. **Session Storage** → Persists user info across page refreshes
4. **Stream URL** → Selected based on hostname (localhost vs production)
5. **UI Updates** → `onAuthStateChanged()` toggles visibility of login/stream

---

## 🔑 AUTHENTICATION SYSTEM

### How It Works

The app uses **Google Sign-In for Web** (OAuth 2.0) with custom email whitelisting.

### Authentication Flow (Detailed)

1. **Page Load** (`auth.js` lines 168-191)

   - Create `GoogleAuth` instance
   - Check if localhost + `DEV_MODE: true` → auto-login as `dev@localhost`
   - Otherwise, check `sessionStorage` for existing session
   - If no session, initialize Google Sign-In API and render button

2. **User Clicks "Sign in with Google"** (`auth.js` lines 88-95)

   - Google renders OAuth popup
   - User selects Google account
   - Google returns JWT credential

3. **Handle Credential Response** (`auth.js` lines 23-51)

   - Parse JWT token to extract email, name, picture
   - Check if email is in `ALLOWED_EMAILS` list
   - If allowed: store user in `sessionStorage`, update UI
   - If denied: show error message

4. **Email Validation** (`auth.js` lines 54-70)

   - Exact match: `email === allowed`
   - Domain match: `email.endsWith(allowed)` for entries starting with `@`
   - Example: `@feralcreative.co` allows `ziad@feralcreative.co`

5. **Session Persistence** (`auth.js` lines 98-106)

   - User info stored in `sessionStorage` (cleared on tab close)
   - On page reload, check session before showing login screen

6. **Sign Out** (`auth.js` lines 108-114)
   - Clear `sessionStorage`
   - Disable Google auto-select
   - Show login screen again

### Key Files & Functions

<augment_code_snippet path="auth.js" mode="EXCERPT">

```javascript
class GoogleAuth {
  constructor() {
    this.user = null;
    this.isInitialized = false;
    this.streamUrlSet = false;
  }
  // ... (lines 1-7)
```

</augment_code_snippet>

<augment_code_snippet path="auth.js" mode="EXCERPT">

```javascript
  isEmailAllowed(email) {
    if (!CONFIG.ALLOWED_EMAILS || CONFIG.ALLOWED_EMAILS.length === 0) {
      return true;
    }
    return CONFIG.ALLOWED_EMAILS.some((allowed) => {
      if (allowed.startsWith("@")) {
        return email.endsWith(allowed); // Domain check
      } else {
        return email === allowed; // Exact email check
      }
    });
  }
  // ... (lines 54-70)
```

</augment_code_snippet>

### Configuration

<augment_code_snippet path="config.js" mode="EXCERPT">

```javascript
const CONFIG = {
  DEV_MODE: true, // Bypass auth on localhost
  GOOGLE_CLIENT_ID: "233064289536-85l4kha72ecka84gmf6f2d1bgkn3h16g.apps.googleusercontent.com",
  ALLOWED_EMAILS: [
    "ziadezzat@gmail.com",
    "@feralcreative.co", // Domain wildcard
    // ... more emails
  ],
  // ... (lines 3-36)
```

</augment_code_snippet>

### Dev Mode Bypass

<augment_code_snippet path="auth.js" mode="EXCERPT">

```javascript
const isLocalhost = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";
if (CONFIG.DEV_MODE && isLocalhost) {
  auth.user = {
    email: "dev@localhost",
    name: "Developer",
    picture: null,
    credential: null,
  };
  auth.onAuthStateChanged();
  return;
}
// ... (lines 172-183)
```

</augment_code_snippet>

---

## 📺 VIDEO STREAMING

### Stream Source

- **Hardware:** Synology NAS (nas.feralcreative.co)
- **Software:** Synology Surveillance Station
- **Camera:** FlashForge Adventurer 5M Pro (built-in camera)
- **Format:** MJPEG (Motion JPEG)
- **Camera ID:** 2

### Stream URLs

<augment_code_snippet path="config.js" mode="EXCERPT">

```javascript
  STREAM_URL: {
    DEV: "http://192.168.86.5:5000/webapi/entry.cgi?api=SYNO.SurveillanceStation.Stream.VideoStreaming&version=1&method=Stream&format=mjpeg&cameraId=2&StmKey=STREAM_KEY",
    PROD: "https://nas.feralcreative.co/webapi/entry.cgi?api=SYNO.SurveillanceStation.Stream.VideoStreaming&version=1&method=Stream&format=mjpeg&cameraId=2&StmKey=STREAM_KEY",
  },
  // ... (lines 39-44)
```

</augment_code_snippet>

**Note:** Replace `STREAM_KEY` with actual key from config.js (see Secrets Reference)

### Stream Selection Logic

<augment_code_snippet path="auth.js" mode="EXCERPT">

```javascript
const isLocalhost = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";
const streamUrl = isLocalhost ? CONFIG.STREAM_URL.DEV : CONFIG.STREAM_URL.PROD;

streamImage.onerror = function () {
  this.src = "./images/offline.jpg"; // Fallback
  this.onerror = null;
};

streamImage.src = streamUrl;
// ... (lines 133-142)
```

</augment_code_snippet>

### Offline Handling

- If stream fails to load, `onerror` handler displays `images/offline.jpg`
- Prevents infinite error loops with `this.onerror = null`

---

## 🎨 STYLING & DESIGN

### SCSS Architecture

The project uses **SCSS** with a modular structure:

1. **`_variables.scss`** - Color palette and fonts
2. **`_mixins.scss`** - Responsive breakpoint utilities
3. **`main.scss`** - Main stylesheet (imports variables and mixins)

### Color Palette

<augment_code_snippet path="styles/scss/\_variables.scss" mode="EXCERPT">

```scss
$color-feral: #880088; // Primary purple
$color-feral-dk: #440044; // Dark purple
$color-fpo: #ff00ff; // Accent magenta

$font-primary: Barlow;
```

</augment_code_snippet>

### Responsive Breakpoints

<augment_code_snippet path="styles/scss/\_mixins.scss" mode="EXCERPT">

```scss
$breakpoints: (
  "xs": 480px,
  "sm": 640px,
  "md": 768px,
  "lg": 1024px,
  "xl": 1280px,
  "xxl": 1536px,
);

@mixin breakpoint($size) {
  @if map-has-key($breakpoints, $size) {
    @media (min-width: map-get($breakpoints, $size)) {
      @content;
    }
  }
}
```

</augment_code_snippet>

### SCSS Compilation

**Automated via Live Sass Compile extension:**

<augment_code_snippet path=".vscode/settings.json" mode="EXCERPT">

```json
{
  "liveSassCompile.settings.formats": [
    {
      "format": "expanded",
      "extensionName": ".css",
      "savePath": "/styles/css"
    },
    {
      "format": "compressed",
      "extensionName": ".min.css",
      "savePath": "/styles/css"
    }
  ],
  "liveSassCompile.settings.generateMap": true,
  "liveSassCompile.settings.autoprefix": ["> 1%", "last 2 versions"],
  "liveSassCompile.settings.includeItems": ["/styles/scss/main.scss"],
  "liveSassCompile.settings.watchOnLaunch": true
}
```

</augment_code_snippet>

**⚠️ IMPORTANT:** Do NOT compile SCSS manually. VS Code handles this automatically.

### Key UI Components

1. **Login Screen** (`.login-screen`) - Purple gradient background, centered Google button
2. **Stream Container** (`.stream-container`) - Full viewport, black background
3. **Hamburger Menu** (`.hamburger-menu`) - Top-left overlay with user info
4. **Stream Image** (`.stream-image`) - Full viewport, object-fit: cover
5. **Corner Logo** (`.corner`) - Bottom-right branding (25vmin)

---

## 📄 HTML STRUCTURE

### Main Sections

<augment_code_snippet path="index.html" mode="EXCERPT">

```html
<body>
  <!-- Login Screen (hidden when authenticated) -->
  <div
    id="login-screen"
    class="login-screen">
    <div class="login-container">
      <img
        class="login-logo"
        src="./images/feral-lockup.svg"
        alt="" />
      <h1>3D Printer Stream</h1>
      <p>Sign in with your Google account to view the stream</p>
      <div id="google-signin-button"></div>
      <div
        id="error-message"
        class="error-message"></div>
    </div>
  </div>

  <!-- Hamburger Menu (shown when authenticated) -->
  <div
    id="hamburger-menu"
    class="hamburger-menu">
    <!-- ... menu content ... -->
  </div>

  <!-- Stream Container (shown when authenticated) -->
  <div
    id="stream-container"
    class="stream-container">
    <a
      href="http://feralcreative.co"
      target="_blank">
      <img
        class="corner"
        src="./images/feral-corner-bottom-right@2x.png"
        alt="Feral Creative" />
    </a>
    <img
      id="stream-image"
      src=""
      alt="3D Printer Stream"
      class="stream-image" />
  </div>
</body>
```

</augment_code_snippet>

### External Dependencies

<augment_code_snippet path="index.html" mode="EXCERPT">

```html
<!-- Google Fonts -->
<link
  href="https://fonts.googleapis.com/css2?family=Barlow:wght@100;200;300;400;500;600;700;800;900&display=swap"
  rel="stylesheet" />

<!-- Google Sign-In API -->
<script
  src="https://accounts.google.com/gsi/client"
  async
  defer></script>

<!-- Local Scripts -->
<script src="./config.js"></script>
<script src="./auth.js"></script>
```

</augment_code_snippet>

---

## 🚢 DEPLOYMENT

### Deployment Target

- **Server:** Synology NAS (nas.feralcreative.co)
- **Protocol:** SFTP
- **Port:** `337**` (see Secrets Reference)
- **Remote Path:** `/web/3d.feralcreative.co`
- **Method:** VS Code SFTP extension

### SFTP Configuration

<augment_code_snippet path=".vscode/sftp.json" mode="EXCERPT">

```json
{
  "name": "nas.feralcreative.co",
  "host": "nas.feralcreative.co",
  "protocol": "sftp",
  "port": SSH_PORT,
  "agent": "$SSH_AUTH_SOCK",
  "username": "ziad",
  "remotePath": "/web/3d.feralcreative.co",
  "uploadOnSave": false,
  "ignore": [
    "**/_*",
    "**/.DS_Store",
    "**/.git**",
    "**/.vscode",
    "**/.secrets/*",
    "*.scss",
    "*.md",
    // ... more exclusions
  ]
}
```

</augment_code_snippet>

### Deployment Workflow

1. **Make changes locally**
2. **Test on Live Server** (http://localhost:5501)
3. **Commit to Git:**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin main
   ```
4. **Deploy via SFTP:**
   - Right-click project folder in VS Code
   - Select "SFTP: Upload Folder"
   - Or use "SFTP: Sync Local → Remote"

### What Gets Deployed

✅ **Included:**

- `index.html`
- `auth.js`
- `config.js`
- `styles/css/*.css` (compiled CSS)
- `images/*`
- `favicon.ico`
- `site.webmanifest`

❌ **Excluded:**

- `styles/scss/*` (source SCSS)
- `.git/`, `.vscode/`, `.secrets/`
- `*.md` files (docs)
- `_archive/`, `_TASKS/`, `data/`
- `node_modules/` (if any)

### Post-Deployment Verification

1. Visit https://3d.feralcreative.co
2. Test Google OAuth login
3. Verify stream loads (or shows offline image)
4. Test hamburger menu and sign-out

---

## 🐛 DEBUGGING & TROUBLESHOOTING

### Common Issues

#### 1. "Access denied" Error

**Symptoms:** User sees error message after signing in with Google

**Causes:**

- Email not in `ALLOWED_EMAILS` list
- Typo in email address in config

**Solutions:**

- Add email to `config.js` (line 17-36)
- Check for exact match or domain wildcard
- Verify email in browser console: `auth.user.email`

#### 2. Sign-In Button Doesn't Appear

**Symptoms:** Login screen shows but no Google button

**Causes:**

- Google API failed to load
- Client ID incorrect
- Domain not in authorized origins

**Solutions:**

- Check browser console for errors
- Verify `GOOGLE_CLIENT_ID` in `config.js`
- Add domain to Google Cloud Console → Credentials → Authorized JavaScript origins

#### 3. Stream Shows Offline Image

**Symptoms:** Authentication works but stream doesn't load

**Causes:**

- NAS is offline or unreachable
- Stream key expired/changed
- Camera ID changed
- Network firewall blocking stream

**Solutions:**

- Check NAS is online: `ping nas.feralcreative.co`
- Verify stream URL in browser directly
- Check Surveillance Station camera settings
- Test DEV URL on local network: `http://192.168.86.5:5000/...`

#### 4. SCSS Not Compiling

**Symptoms:** Changes to SCSS don't appear in browser

**Causes:**

- Live Sass Compile extension not running
- Wrong save path configured
- SCSS syntax error

**Solutions:**

- Check VS Code status bar for "Watching..." indicator
- Click "Watch Sass" in status bar
- Check Output panel for SCSS errors
- Verify `.vscode/settings.json` configuration

#### 5. SFTP Upload Fails

**Symptoms:** Can't deploy to production server

**Causes:**

- SSH key not configured
- Wrong port number
- Network connectivity issue
- Permissions on remote server

**Solutions:**

- Test SSH connection: `ssh -p SSH_PORT ziad@nas.feralcreative.co`
- Verify SSH agent is running: `ssh-add -l`
- Check `.vscode/sftp.json` configuration
- Verify remote path exists and is writable

### Debugging Tools

#### Browser Console

```javascript
// Check auth state
console.log(auth.user);

// Check config
console.log(CONFIG);

// Test email validation
console.log(auth.isEmailAllowed("test@example.com"));

// Check stream URL
console.log(document.getElementById("stream-image").src);
```

#### Network Tab

- Filter by "cgi" to see stream requests
- Check for 401/403 errors (auth issues)
- Check for 404 errors (wrong URL)
- Look for CORS errors

#### VS Code Output Panel

- **Live Sass Compile** - SCSS compilation errors
- **SFTP** - Upload/download logs

---

## 📋 DEVELOPMENT TASKS

### Common Tasks

#### Add New Authorized Email

1. Open `config.js`
2. Add email to `ALLOWED_EMAILS` array (line 17-36)
3. Save file
4. Deploy to production

#### Update Stream URL

1. Open `config.js`
2. Update `STREAM_URL.DEV` or `STREAM_URL.PROD` (lines 41, 43)
3. Save file
4. Deploy to production

#### Change Styling

1. Edit SCSS files in `styles/scss/`
2. Live Sass Compile auto-generates CSS
3. Test in browser (Live Server auto-refreshes)
4. Commit and deploy

#### Add Menu Link

1. Open `index.html`
2. Find `<nav class="menu-links">` (line 57)
3. Add new `<a>` tag
4. Save, test, deploy

#### Rotate Stream Key

1. Log into Synology Surveillance Station
2. Generate new stream key for Camera 2
3. Update `config.js` lines 41 and 43
4. Deploy to production

---

## 🔄 GIT WORKFLOW

### Repository Info

- **Remote:** https://github.com/feralcreative/3d.feralcreative.co.git
- **Branch:** `main` (default)
- **Last Commit:** `c6c8b5a - site live`

### Commit History

```bash
c6c8b5a (HEAD -> main, origin/main) site live
cf1ee18 initial commit
```

### Standard Workflow

```bash
# Check status
git status

# Stage changes
git add .

# Commit with message
git commit -m "Description of changes"

# Push to GitHub
git push origin main

# Pull latest changes
git pull origin main
```

### .gitignore Highlights

- `.secrets/*` - OAuth credentials
- `.vscode/` - Editor config (includes sftp.json)
- `styles/css/*` - Compiled CSS (regenerated from SCSS)
- `*.css.map` - Source maps
- `_archive/`, `_TASKS/` - Working directories
- `.DS_Store` - macOS system files

---

## 📚 DOCUMENTATION

### Existing Docs

1. **`docs/GOOGLE_AUTH_SETUP.md`** - Complete OAuth setup guide
2. **`_AI_AGENT_PRIMER.md`** - This file
3. **`_NOTES.md`** - Development notes (minimal)
4. **`README.md`** - Empty (needs content)

### Documentation Gaps

- [ ] README.md needs project overview
- [ ] No deployment guide (covered here)
- [ ] No troubleshooting guide (covered here)
- [ ] No API documentation for stream endpoints

---

## ⚠️ KNOWN ISSUES

### Current Bugs

None reported.

### Incomplete Features

1. **No session timeout** - Users stay logged in until tab closes
2. **No refresh token** - Must re-authenticate after session expires
3. **No loading indicator** - Stream appears instantly or shows offline image
4. **No stream quality controls** - Fixed MJPEG quality from NAS

### Technical Debt

1. **Hardcoded stream key** - Should be environment variable
2. **No error logging** - Errors only visible in browser console
3. **No analytics** - Can't track usage or errors
4. **No automated tests** - All testing is manual
5. **No CI/CD pipeline** - Manual deployment via SFTP

---

## 🚀 NEXT STEPS & ROADMAP

### High Priority

1. **Add README.md content** - Project overview, setup instructions
2. **Implement session timeout** - Auto-logout after X minutes
3. **Add loading indicator** - Show spinner while stream loads
4. **Move stream key to environment variable** - Improve security

### Medium Priority

5. **Add error logging** - Send errors to external service (e.g., Sentry)
6. **Implement analytics** - Track page views, auth events
7. **Add stream quality selector** - Let users choose resolution
8. **Create automated tests** - Unit tests for auth logic

### Low Priority

9. **Add dark/light mode toggle** - User preference
10. **Implement PWA features** - Offline support, install prompt
11. **Add admin panel** - Manage allowed emails without editing code
12. **Create CI/CD pipeline** - Auto-deploy on git push

---

## 🎓 ARCHITECTURAL DECISIONS (WHY?)

### Why Vanilla JavaScript?

- **Simplicity:** No build process, no dependencies
- **Performance:** Minimal overhead, fast load times
- **Maintainability:** Easy to understand, no framework lock-in

### Why Google OAuth?

- **Security:** Industry-standard authentication
- **UX:** Users already have Google accounts
- **Email Whitelisting:** Built-in support for domain restrictions

### Why MJPEG Stream?

- **Compatibility:** Works in all browsers without plugins
- **Simplicity:** No complex video player needed
- **Real-time:** Low latency compared to HLS/DASH

### Why Synology NAS?

- **Existing Infrastructure:** Already hosting other services
- **Surveillance Station:** Built-in camera management
- **Reliability:** 24/7 uptime, RAID storage

### Why SFTP Deployment?

- **Security:** Encrypted file transfer
- **Simplicity:** No complex CI/CD setup needed
- **Control:** Manual deployment prevents accidental pushes

### Why SCSS?

- **Variables:** Centralized color/font management
- **Mixins:** Reusable responsive breakpoints
- **Nesting:** Cleaner, more maintainable code

---

## 🔧 DEVELOPMENT ENVIRONMENT

### Required VS Code Extensions

1. **Live Server** (ritwickdey.LiveServer)

   - Launches local dev server on port 5501
   - Auto-refreshes browser on file changes

2. **Live Sass Compile** (glenn2223.live-sass)

   - Auto-compiles SCSS to CSS on save
   - Generates source maps and minified versions

3. **SFTP** (Natizyskunk.sftp) - Optional
   - Deploys files to production server
   - Configured via `.vscode/sftp.json`

### VS Code Settings

<augment_code_snippet path=".vscode/settings.json" mode="EXCERPT">

```json
{
  "liveServer.settings.port": 5501,
  "liveSassCompile.settings.watchOnLaunch": true
}
```

</augment_code_snippet>

### Local Development URLs

- **Dev Server:** http://localhost:5501
- **Stream (DEV):** http://192.168.86.5:5000/webapi/... (local network only)

### Production URLs

- **Website:** https://3d.feralcreative.co
- **Stream (PROD):** https://nas.feralcreative.co/webapi/...

---

## 📊 PROJECT STATISTICS

- **Total Files:** ~30 (excluding .git, node_modules, etc.)
- **Lines of Code:**
  - JavaScript: ~200 lines (auth.js + config.js)
  - HTML: ~100 lines (index.html)
  - SCSS: ~220 lines (main.scss + partials)
- **Dependencies:** 0 (no package.json)
- **External APIs:** 2 (Google Sign-In, Synology Surveillance Station)
- **Commits:** 2
- **Contributors:** 1 (Ziad)

---

## 🎯 SUCCESS CRITERIA CHECKLIST

✅ **Another AI agent can:**

- [ ] Clone repo and understand project in 5 minutes
- [ ] Start development without asking questions
- [ ] Find all credentials via Secrets Reference
- [ ] Deploy to production successfully
- [ ] Debug common issues independently

✅ **Security:**

- [ ] No exposed secrets in this document
- [ ] All credentials obfuscated with file locations
- [ ] Safe to commit to public repository

✅ **Completeness:**

- [ ] All architecture decisions explained
- [ ] All file purposes documented
- [ ] All workflows described
- [ ] All known issues listed

---

## 📞 SUPPORT & CONTACTS

- **Developer:** Ziad (ziadezzat@gmail.com)
- **Repository:** https://github.com/feralcreative/3d.feralcreative.co
- **Production Site:** https://3d.feralcreative.co
- **Company:** Feral Creative (http://feralcreative.co)

---

**Last Updated:** 2026-01-05
**Version:** 1.0
**Status:** Production Live
