#!/bin/bash
set -euo pipefail

APP_NAME="FTMarkdown"
SCHEME="FTMarkdown"
PROJECT="${APP_NAME}.xcodeproj"
SIGNING_IDENTITY="Developer ID Application: Reagen Ward (S7727758YQ)"
KEYCHAIN_PROFILE="notarytool-profile"
BUILD_DIR="$(pwd)/build"
DMG_PATH="${BUILD_DIR}/${APP_NAME}.dmg"
DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

echo "==> Generating Xcode project..."
xcodegen generate

echo "==> Cleaning..."
DEVELOPER_DIR="$DEVELOPER_DIR" xcodebuild -project "$PROJECT" -scheme "$SCHEME" clean 2>&1 | tail -1

echo "==> Building..."
DEVELOPER_DIR="$DEVELOPER_DIR" xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
  -configuration Release \
  CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM=S7727758YQ \
  OTHER_CODE_SIGN_FLAGS="--timestamp --options runtime" \
  build \
  SYMROOT="$BUILD_DIR" 2>&1 | tail -5

APP_PATH="$BUILD_DIR/Release/${APP_NAME}.app"

if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: Build failed — $APP_PATH not found"
  exit 1
fi

echo "==> Verifying code signature..."
codesign --verify --deep --strict "$APP_PATH"
echo "    Signature OK"

echo "==> Creating DMG..."
rm -f "$DMG_PATH"
hdiutil create -volname "$APP_NAME" -srcfolder "$APP_PATH" -ov -format UDZO "$DMG_PATH" 2>&1 | tail -1

echo "==> Submitting for notarization..."
xcrun notarytool submit "$DMG_PATH" --keychain-profile "$KEYCHAIN_PROFILE" --wait

echo "==> Stapling..."
xcrun stapler staple "$DMG_PATH"

echo ""
echo "Done! Notarized DMG: $DMG_PATH"
