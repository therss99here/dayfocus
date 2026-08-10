#!/bin/sh

# Xcode Cloud post-clone script
# Installs Flutter and CocoaPods dependencies

set -e

# Install Flutter
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Precache iOS artifacts FIRST (before any pod install happens)
echo "Precaching iOS artifacts..."
flutter precache --ios -v

# Verify the framework exists
echo "Checking for Flutter.xcframework..."
ls -la $HOME/flutter/bin/cache/artifacts/engine/ios/ || echo "iOS engine directory not found"

# Disable Swift Package Manager (experimental, causes issues in CI)
flutter config --no-enable-swift-package-manager

# Flutter doctor
flutter doctor -v

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

# Get Flutter dependencies (this may run pod install)
echo "Getting Flutter dependencies..."
flutter pub get

# Build iOS to ensure everything is set up
echo "Building iOS configuration..."
flutter build ios --config-only --no-codesign --dart-define-from-file=env.json

echo "CI post-clone completed successfully"

echo "CI post-clone completed successfully"
