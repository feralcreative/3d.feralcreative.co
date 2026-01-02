# Google Authentication Setup

This document explains how to configure Google OAuth 2.0 authentication for the 3D Printer Stream application.

## Prerequisites

- A Google Cloud project
- Access to Google Cloud Console

## Step 1: Create OAuth 2.0 Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create a new one)
3. Navigate to **APIs & Services** > **Credentials**
4. Click **Create Credentials** > **OAuth client ID**
5. If prompted, configure the OAuth consent screen first:
   - Choose **Internal** (if using Google Workspace) or **External**
   - Fill in the required fields (app name, user support email, developer contact)
   - Add scopes: `email` and `profile` (these are default and sufficient)
   - Save and continue

## Step 2: Configure OAuth Client ID

1. Choose **Web application** as the application type
2. Give it a name (e.g., "3D Printer Stream")
3. Add **Authorized JavaScript origins**:
   - For local development: `http://localhost:5501`
   - For production: `https://3d.feralcreative.co` (or your actual domain)
4. You don't need to add redirect URIs for this implementation
5. Click **Create**
6. Copy the **Client ID** (it will look like `xxxxx-xxxxx.apps.googleusercontent.com`)

## Step 3: Configure the Application

1. Open `config.js` in your project
2. Replace `YOUR_CLIENT_ID_HERE.apps.googleusercontent.com` with your actual Client ID
3. (Optional) Configure email restrictions:
   ```javascript
   // Allow only specific email addresses
   ALLOWED_EMAILS: ['ziad@feralcreative.co']
   
   // Or allow any email from a domain
   ALLOWED_EMAILS: ['@feralcreative.co']
   
   // Or allow any Google account (leave empty)
   ALLOWED_EMAILS: []
   ```

## Step 4: Test Locally

1. Start your local server (e.g., Live Server on port 5501)
2. Open the page in your browser
3. You should see the login screen
4. Click "Sign in with Google"
5. Authenticate with your Google account
6. If successful, you'll see the stream

## Step 5: Deploy to Production

1. Make sure your production domain is added to **Authorized JavaScript origins** in Google Cloud Console
2. Deploy your files to your production server
3. Test the authentication flow on the production domain

## Security Notes

- The `config.js` file contains your Client ID, which is **public** and safe to commit to version control
- Client IDs are designed to be public - they only work with authorized domains
- Never share your Client Secret (not used in this implementation)
- Session data is stored in `sessionStorage` and cleared when the browser tab is closed
- For production, consider adding your domain to the `ALLOWED_EMAILS` restriction

## Troubleshooting

### "Access denied" error
- Check that your email is in the `ALLOWED_EMAILS` list (if configured)
- Verify the email restrictions in `config.js`

### Sign-in button doesn't appear
- Check browser console for errors
- Verify your Client ID is correct in `config.js`
- Make sure the current domain is in Authorized JavaScript origins

### "redirect_uri_mismatch" error
- This shouldn't happen with this implementation, but if it does:
- Verify the domain in Authorized JavaScript origins matches exactly (including http/https)
- Clear browser cache and try again

## Files Modified

- `index.html` - Added authentication UI and Google Sign-In API
- `auth.js` - Authentication logic and session management
- `config.js` - OAuth Client ID configuration
- `styles/scss/main.scss` - Styles for login screen and user info bar

