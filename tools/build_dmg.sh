#!/bin/bash
set -e

echo "=== Building Blur Glass for macOS (Release) ==="

# 1. Regenerate App Icons
swift tools/generate_icons.swift macos/Runner/Assets.xcassets/AppIcon.appiconset

# 2. Build Release macOS App Bundle
flutter build macos --release

APP_PATH="build/macos/Build/Products/Release/Blur Glass.app"
if [ ! -d "$APP_PATH" ]; then
    APP_PATH="build/macos/Build/Products/Release/blur_glass.app"
fi

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Release .app bundle not found at $APP_PATH"
    exit 1
fi

echo "Found release app at: $APP_PATH"

# 3. Setup Dist & Staging Directory
DIST_DIR="dist"
STAGING_DIR="build/dmg_staging"
DMG_NAME="BlurGlass-1.0.0.dmg"
DMG_PATH="$DIST_DIR/$DMG_NAME"
LATEST_DMG_PATH="$DIST_DIR/BlurGlass.dmg"

mkdir -p "$DIST_DIR"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# 4. Copy App Bundle & Create /Applications symlink
echo "Staging application bundle..."
cp -R "$APP_PATH" "$STAGING_DIR/Blur Glass.app"
ln -s /Applications "$STAGING_DIR/Applications"

# 5. Create compressed DMG using hdiutil
echo "Creating DMG package: $DMG_PATH"
rm -f "$DMG_PATH" "$LATEST_DMG_PATH"

hdiutil create \
    -volname "Blur Glass" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

cp "$DMG_PATH" "$LATEST_DMG_PATH"

echo "=== DMG Packaging Complete! ==="
echo "Artifact: $DMG_PATH"
echo "Artifact: $LATEST_DMG_PATH"
