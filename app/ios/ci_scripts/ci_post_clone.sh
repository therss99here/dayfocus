#!/bin/sh

# Xcode Cloud post-clone script
# Installs Flutter and CocoaPods dependencies

set -e

# Install Flutter
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Flutter doctor
flutter doctor

# Navigate to app directory
cd "$CI_PRIMARY_REPOSITORY_PATH/app"

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Navigate to iOS directory and install pods
cd ios
echo "Installing CocoaPods dependencies..."
pod install

echo "CI post-clone completed successfully"
