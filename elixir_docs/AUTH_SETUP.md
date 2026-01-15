# Google Authentication Setup

This application requires Google OAuth authentication for all users.

## Quick Start

1. **Set up Google OAuth credentials** (see detailed steps below)
2. **Create dev.env file**:
   ```bash
   cp example.env dev.env
   # Edit dev.env with your Google OAuth credentials
   ```
3. **Start the development server**:
   ```bash
   ./start_dev.sh
   ```
4. **Visit http://localhost:4000** - you'll be redirected to the login page

## Google Cloud Console Setup

### 1. Create a Google Cloud Project
1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google+ API or Google Identity Services

### 2. Configure OAuth Consent Screen
1. Navigate to **APIs & Services > OAuth consent screen**
2. Choose **External** user type
3. Fill in the required information:
   - Application name: `LiveAiChat`
   - Support email: Your email
   - Developer contact: Your email
4. Add scopes: `email`, `profile`, `openid`
5. Save and continue

### 3. Create OAuth 2.0 Credentials
1. Navigate to **APIs & Services > Credentials**
2. Click **Create Credentials > OAuth client ID**
3. Choose **Web application**
4. Configure settings:
   - **Name**: `LiveAiChat Development`
   - **Authorized JavaScript origins**: 
     - `http://localhost:4000`
     - Add your production domain later
   - **Authorized redirect URIs**:
     - `http://localhost:4000/auth/google/callback`
     - Add your production callback URL later
5. Click **Create**
6. Copy the **Client ID** and **Client Secret**

### 4. Configure Environment Variables
Create or update your `dev.env` file:
```bash
GOOGLE_CLIENT_ID=your_client_id_here.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-your_client_secret_here
```

## Authentication Flow

1. **Unauthenticated users** → Redirected to `/login`
2. **Login page** → Shows "Sign in with Google" button
3. **Google OAuth** → User authenticates with Google
4. **Callback** → User data stored in session, redirected to app
5. **Authenticated users** → Can access all app features
6. **Logout** → Clears session, redirects to login

## Troubleshooting

### Error: "Missing required parameter: client_id"
- Make sure `dev.env` exists with correct Google OAuth credentials
- Start the server with `./start_dev.sh` to load environment variables
- Verify credentials in Google Cloud Console

### Error: "redirect_uri_mismatch"
- Check that redirect URI in Google Cloud Console matches: `http://localhost:4000/auth/google/callback`
- Ensure port matches your development server (default: 4000)

### Error: "access_denied"
- User cancelled the OAuth flow
- Check OAuth consent screen configuration
- Ensure your Google account has access to the application

## Production Setup

For production deployment:
1. Add your production domain to authorized origins in Google Cloud Console
2. Set environment variables in your production environment
3. Use HTTPS for all OAuth redirects in production

## File Structure

- `lib/live_ai_chat_web/live/login_live.ex` - Login page LiveView
- `lib/live_ai_chat_web/controllers/auth_controller.ex` - OAuth flow handling
- `lib/live_ai_chat_web/plugs/require_auth.ex` - Authentication middleware
- `start_dev.sh` - Development server with environment loading
