# Google Sign-In Setup Guide 🔐

Follow these steps to configure Google Sign-In for your Sadhana app:

## 📋 **Prerequisites**
- Google account
- Access to [Google Cloud Console](https://console.cloud.google.com/)

## 🚀 **Step-by-Step Setup**

### **Step 1: Create Google Cloud Project**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Name your project: `Sadhana App` 
4. Click "Create"

### **Step 2: Enable Google Sign-In API**
1. In your project, go to **"APIs & Services"** → **"Library"**
2. Search for **"Google Sign-In API"** or **"Google+ API"**
3. Click on it and press **"Enable"**

### **Step 3: Create OAuth 2.0 Credentials**
1. Go to **"APIs & Services"** → **"Credentials"**
2. Click **"Create Credentials"** → **"OAuth 2.0 Client IDs"**
3. If prompted, configure the OAuth consent screen:
   - Choose **"External"** user type
   - Fill in app name: `Sadhana App`
   - Add your email as developer contact
   - Save and continue through the scopes and test users steps

4. **Configure OAuth Client ID:**
   - Application type: **"Web application"**
   - Name: `Sadhana Web Client`
   - **Authorized JavaScript origins:**
     - `http://localhost:8080` (for development)
     - `http://localhost:3000` (alternative port)
     - Add your production domain when ready
   - **Authorized redirect URIs:** (leave empty for now)

5. Click **"Create"**
6. **Copy the Client ID** (it looks like: `123456789-abcdefghijk.apps.googleusercontent.com`)

### **Step 4: Configure Your App**

#### **For Web (Current Setup):**
1. Open `web/index.html`
2. Replace `YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com` with your actual Client ID:
   ```html
   <meta name="google-signin-client_id" content="123456789-abcdefghijk.apps.googleusercontent.com">
   ```

#### **Alternative: Set in Code (Optional):**
1. Open `lib/services/auth_service.dart`
2. Uncomment and update the clientId line:
   ```dart
   final GoogleSignIn _googleSignIn = GoogleSignIn(
     scopes: ['email', 'profile'],
     clientId: '123456789-abcdefghijk.apps.googleusercontent.com', // Your Client ID here
   );
   ```

### **Step 5: Test Your Setup**
1. Save your changes
2. Run the app: `flutter run -d chrome --web-port=8080`
3. Click "Continue with Google"
4. You should see the Google Sign-In popup!

## 🔧 **For Mobile Apps (iOS & Android)**

### **iOS Setup:**
1. In Google Cloud Console, create another OAuth Client ID
2. Choose **"iOS"** as application type
3. Enter your iOS bundle ID (from `ios/Runner.xcodeproj`)
4. Download the `GoogleService-Info.plist` file
5. Add it to `ios/Runner/` in Xcode

### **Android Setup:**
1. Create another OAuth Client ID for **"Android"**
2. Get your SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
3. Enter the SHA-1 fingerprint and package name
4. Download `google-services.json`
5. Place it in `android/app/`

## 🎯 **Demo Mode**
If you haven't set up Google OAuth yet, the app will automatically fall back to **Demo Mode** with a test user:
- Name: Demo Devotee
- Email: demo@sadhana.app

This lets you test all app features while setting up Google authentication!

## 🔍 **Troubleshooting**

### **Common Issues:**

1. **"ClientID not set" error:**
   - Make sure you've added the meta tag to `web/index.html`
   - Verify the Client ID is correct (no extra spaces/characters)

2. **"Invalid Origin" error:**
   - Add `http://localhost:8080` to authorized JavaScript origins
   - Make sure the port matches where you're running the app

3. **"This app isn't verified" warning:**
   - Normal for development apps
   - Click "Advanced" → "Go to Sadhana App (unsafe)" for testing
   - For production, submit for Google verification

4. **Popup blocked:**
   - Allow popups for localhost in your browser
   - Try using incognito/private browsing mode

## 📱 **Production Deployment**
When deploying to production:
1. Add your production domain to authorized JavaScript origins
2. Update the redirect URIs if needed
3. Consider submitting for Google verification
4. Set up proper Firebase hosting if using Firebase

## 🙏 **Ready to Track Your Sadhana!**
Once configured, devotees can:
- Sign in securely with their Google accounts
- Track their daily spiritual practices
- RSVP to temple events
- Join the spiritual community

**Hare Krishna!** 🌺 