# Sadhana UI Deployment Guide

## Overview
This guide explains how to deploy the Sadhana Flutter UI to Vercel and connect it with the deployed backend API on Render.

## Prerequisites
- Flutter SDK installed and configured
- Vercel CLI installed (`npm i -g vercel`)
- Git repository set up

## Backend API
The backend is already deployed on Render at: https://sadhana-api.onrender.com

Health check: https://sadhana-api.onrender.com/api/actuator/health

## Deployment Steps

### 1. Build the Flutter Web App
```bash
# Run the build script
./build.sh

# Or manually:
flutter clean
flutter pub get
flutter build web --release --web-renderer html
```

### 2. Deploy to Vercel

#### Option A: Using Vercel CLI
```bash
# Install Vercel CLI if not already installed
npm i -g vercel

# Login to Vercel
vercel login

# Deploy from the project root
vercel

# Follow prompts:
# - Set up and deploy? Yes
# - Which scope? (select your account)
# - Link to existing project? No
# - What's your project's name? sadhana-ui
# - In which directory is your code located? ./
# - Want to override the settings? Yes
# - Build Command: flutter build web --release
# - Output Directory: build/web
# - Development Command: flutter run -d web-server --web-port 3000
```

#### Option B: Using GitHub Integration
1. Push your code to GitHub
2. Go to https://vercel.com
3. Import your GitHub repository
4. Configure build settings:
   - Build Command: `flutter build web --release`
   - Output Directory: `build/web`
   - Install Command: `flutter pub get`

### 3. Environment Configuration

The app is already configured to use the production API:
- API Base URL: `https://sadhana-api.onrender.com/api`

### 4. Custom Domain (Optional)
If you want to use a custom domain:
1. Go to your Vercel project dashboard
2. Go to Settings > Domains
3. Add your custom domain
4. Update DNS records as instructed

## Vercel Configuration

The project includes a `vercel.json` file with the following configuration:
```json
{
  "version": 2,
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "routes": [
    {
      "src": "/.*",
      "dest": "/index.html"
    }
  ]
}
```

## Features
- ✅ Progressive Web App (PWA) support
- ✅ Single Page Application (SPA) routing
- ✅ Mobile-responsive design
- ✅ Google OAuth authentication
- ✅ Connected to production API on Render

## Troubleshooting

### Build Issues
1. Ensure Flutter SDK is properly installed
2. Run `flutter doctor` to check for issues
3. Clear build cache: `flutter clean`

### API Connection Issues
1. Check backend health: https://sadhana-api.onrender.com/api/actuator/health
2. Verify CORS settings on backend
3. Check browser developer tools for network errors

### Deployment Issues
1. Ensure build completes successfully locally
2. Check Vercel build logs
3. Verify `vercel.json` configuration

## Post-Deployment Testing

Test the following functionality:
1. ✅ App loads correctly
2. ✅ Google OAuth login works
3. ✅ Demo login works
4. ✅ API connectivity (check network tab)
5. ✅ Navigation between screens
6. ✅ Data persistence
7. ✅ Mobile responsiveness

## Links
- **Frontend (Vercel)**: [Will be provided after deployment]
- **Backend (Render)**: https://sadhana-api.onrender.com
- **API Health**: https://sadhana-api.onrender.com/api/actuator/health
