#!/bin/sh

# Xcode Cloud post-clone script
# Installs Flutter and CocoaPods dependencies

set -e

# Keepalive: print a dot every 60s to prevent Xcode Cloud inactivity timeout
keepalive() {
  while true; do sleep 60; echo "... still running ($1)"; done
}

# Install Flutter
echo "Installing Flutter..."
keepalive "flutter install" &
KEEPALIVE_PID=$!
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
kill $KEEPALIVE_PID 2>/dev/null || true
export PATH="$PATH:$HOME/flutter/bin"

# CRITICAL: Disable Swift Package Manager FIRST before any Flutter commands
echo "Disabling Swift Package Manager..."
flutter config --no-enable-swift-package-manager

# Precache iOS artifacts
echo "Precaching iOS artifacts..."
keepalive "precache" &
KEEPALIVE_PID=$!
flutter precache --ios
kill $KEEPALIVE_PID 2>/dev/null || true

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

# Create env.dart (gitignored, contains secrets)
echo "Creating env.dart from environment variables..."
cat > lib/core/config/env.dart << EOF
const supabaseUrl = '${SUPABASE_URL}';
const supabaseAnonKey = '${SUPABASE_ANON_KEY}';
const googleClientIdIos = '${GOOGLE_CLIENT_ID_IOS}';
const googleClientIdWeb = '${GOOGLE_CLIENT_ID_WEB}';
const revenuecatApiKey = '${REVENUECAT_API_KEY}';
EOF

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# .g.dart files are tracked in git — no build_runner needed in CI

# Generate iOS project files (creates AppFrameworkInfo.plist, etc.)
echo "Generating iOS project files..."
keepalive "ios config" &
KEEPALIVE_PID=$!
flutter build ios --config-only --no-codesign
kill $KEEPALIVE_PID 2>/dev/null || true

# Install pods manually (more reliable in CI)
cd ios
echo "Installing CocoaPods dependencies..."
pod install

echo "CI post-clone completed successfully"
