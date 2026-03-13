#!/bin/bash
set -euo pipefail

APP_NAME="FTMarkdown"
SCHEME="FTMarkdown"
PROJECT="${APP_NAME}.xcodeproj"
SIGNING_IDENTITY="Developer ID Application: Reagen Ward (S7727758YQ)"
KEYCHAIN_PROFILE="notarytool-profile"
BUILD_DIR="/tmp/ftmarkdown-build"
DMG_PATH="${BUILD_DIR}/${APP_NAME}.dmg"
DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

echo "==> Generating Xcode project..."
xcodegen generate

echo "==> Building (unsigned)..."
DEVELOPER_DIR="$DEVELOPER_DIR" xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO \
  build \
  SYMROOT="$BUILD_DIR" 2>&1 | tail -3

APP_PATH="$BUILD_DIR/Release/${APP_NAME}.app"

if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: Build failed — $APP_PATH not found"
  exit 1
fi

echo "==> Signing components with Developer ID..."

# Sign inside-out: bundles, then extensions, then CLI, then app
find "$APP_PATH" -name "*.bundle" -print0 | while IFS= read -r -d '' f; do
  echo "    Signing: $(basename "$f")"
  codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$f"
done

find "$APP_PATH" -name "*.appex" -print0 | while IFS= read -r -d '' f; do
  echo "    Signing: $(basename "$f")"
  codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$f"
done

echo "    Signing: mdview"
codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$APP_PATH/Contents/Resources/mdview"

echo "    Signing: ${APP_NAME}.app"
codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$APP_PATH"

echo "==> Verifying code signature..."
codesign --verify --deep "$APP_PATH"
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
