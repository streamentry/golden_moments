#!/bin/bash

# Recreate iOS Project - The Standard Flutter Way
# This script removes the old iOS project and creates a new, clean one from scratch

set -e  # Exit on any error

echo "🏗️  Recreating iOS project from scratch..."

# Step 1: Remove the old iOS project
echo "🗑️  Step 1: Removing old iOS project..."
rm -rf ios
echo "   ✅ Old iOS project removed"

# Step 2: Let Flutter create a new, clean iOS project
echo "🚀 Step 2: Creating new iOS project..."
flutter create . --platforms=ios
echo "   ✅ New iOS project created"

# Step 3: Get dependencies and install pods
echo "📦 Step 3: Installing dependencies..."
flutter pub get

# Set iOS version in Podfile
echo "   Setting iOS version in Podfile..."
# Manually set iOS 15.0 for Firebase compatibility
sed -i '' 's/# platform :ios, '\''12.0'\''/platform :ios, '\''15.0'\''/g' ios/Podfile || echo "   Manual Podfile update needed for iOS 15.0"

cd ios
pod install
cd ..
echo "   ✅ Dependencies installed"

# Step 4: Test the new project with a clean build
echo "🔨 Step 4: Testing clean production build..."
flutter build ios --release --no-codesign

echo ""
echo "🎉 iOS Project Recreated Successfully!"
echo ""
echo "✅ What was accomplished:"
echo "   • Removed the old, complex iOS project"
echo "   • Created a new, standard Flutter iOS project"
echo "   • Installed all dependencies cleanly"
echo "   • Successfully built for production"
echo ""
echo "🚀 Ready for App Store:"
echo "   1. Open: open ios/Runner.xcworkspace"
echo "   2. Configure your signing and capabilities in Xcode"
echo "   3. Select 'Any iOS Device'"
echo "   4. Product → Archive"
echo ""
