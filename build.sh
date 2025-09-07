#!/bin/bash

echo "🚀 Building Sadhana UI for Vercel deployment..."

# Ensure Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH. Please install Flutter first."
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "🌐 Building Flutter web app..."
flutter build web --release --web-renderer html

# Check if build was successful
if [ -d "build/web" ]; then
    echo "✅ Build completed successfully!"
    echo "📁 Build output is in: build/web"
    echo "🔗 Ready for deployment to Vercel"
    
    # Show build size
    if command -v du &> /dev/null; then
        echo "📊 Build size:"
        du -sh build/web
    fi
else
    echo "❌ Build failed!"
    exit 1
fi
