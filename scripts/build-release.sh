#!/bin/bash
set -euo pipefail

DEVELOPER_ID="Developer ID Application: Reagen Ward (7U6R5U85F6)"
APP_NAME="FidMDViewer"
SCHEME="FidMDViewer"
BUILD_DIR="build/Release"
DMG_NAME="FidMDViewer.dmg"

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

echo "=== Building universal binary ==="
xcodebuild -project "${APP_NAME}.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "build/${APP_NAME}.xcarchive" \
    archive \
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO

echo "=== Exporting archive ==="
xcodebuild -exportArchive \
    -archivePath "build/${APP_NAME}.xcarchive" \
    -exportOptionsPlist ExportOptions.plist \
    -exportPath "$BUILD_DIR"

echo "=== Verifying code signature ==="
codesign --verify --deep --strict "${BUILD_DIR}/${APP_NAME}.app"
spctl --assess --type execute "${BUILD_DIR}/${APP_NAME}.app"

echo "=== Notarizing ==="
xcrun notarytool submit "${BUILD_DIR}/${APP_NAME}.app" \
    --keychain-profile "notarization-profile" \
    --wait

echo "=== Stapling ==="
xcrun stapler staple "${BUILD_DIR}/${APP_NAME}.app"

echo "=== Creating DMG ==="
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$BUILD_DIR/${APP_NAME}.app" \
    -ov -format UDZO \
    "build/${DMG_NAME}"

echo "=== Notarizing DMG ==="
xcrun notarytool submit "build/${DMG_NAME}" \
    --keychain-profile "notarization-profile" \
    --wait

xcrun stapler staple "build/${DMG_NAME}"

echo "=== Done ==="
echo "Output: build/${DMG_NAME}"
