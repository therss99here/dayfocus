#!/bin/sh

# Xcode Cloud post-clone script
# Installs Flutter and CocoaPods dependencies

set -e

# Install Flutter
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# CRITICAL: Disable Swift Package Manager FIRST before any Flutter commands
echo "Disabling Swift Package Manager..."
flutter config --no-enable-swift-package-manager

# Precache iOS artifacts
echo "Precaching iOS artifacts..."
flutter precache --ios

# Navigate to app directory
cd "$CI_PRIMARY_REPOSITORY_PATH/app"

# Create env.json from Xcode Cloud environment variables
echo "Creating env.json from environment variables..."
cat > env.json << EOF
{
  "SUPABASE_URL": "${SUPABASE_URL}",
  "SUPABASE_ANON_KEY": "${SUPABASE_ANON_KEY}",
  "GOOGLE_CLIENT_ID_IOS": "${GOOGLE_CLIENT_ID_IOS}",
  "GOOGLE_CLIENT_ID_WEB": "${GOOGLE_CLIENT_ID_WEB}",
  "REVENUECAT_API_KEY": "${REVENUECAT_API_KEY}"
}
EOF

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Install pods manually (more reliable in CI)
cd ios
echo "Installing CocoaPods dependencies..."
pod install

echo "CI post-clone completed successfully"

echo "CI post-clone completed successfully"
