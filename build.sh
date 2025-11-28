#!/bin/bash
set -e

# Clean previous build
# rm -rf .build
rm -rf Build
mkdir -p Build

# Build with SPM
echo "Building with SPM..."
swift build

# Get build path
BUILD_PATH=$(swift build --show-bin-path)
echo "Build path: $BUILD_PATH"

# --- Package DummyApp ---
echo "Packaging DummyApp..."
DUMMY_APP_PATH="Build/DummyApp.app"
mkdir -p "$DUMMY_APP_PATH/Contents/MacOS"
mkdir -p "$DUMMY_APP_PATH/Contents/Resources"

cp "$BUILD_PATH/DummyApp" "$DUMMY_APP_PATH/Contents/MacOS/"
cp "Sources/DummyApp/Resources/Info.plist.src" "$DUMMY_APP_PATH/Contents/Info.plist"
cp "Sources/SWDA-Prefpane/Resources/Unsupported.icns" "$DUMMY_APP_PATH/Contents/Resources/"

# --- Package Prefpane ---
echo "Packaging SwiftDefaultApps.prefpane..."
PREFPANE_PATH="Build/SwiftDefaultApps.prefpane"
mkdir -p "$PREFPANE_PATH/Contents/MacOS"
mkdir -p "$PREFPANE_PATH/Contents/Resources"

# Copy binary
cp "$BUILD_PATH/libSWDAPrefpane.dylib" "$PREFPANE_PATH/Contents/MacOS/SwiftDefaultApps"

# Copy Info.plist
cp "Sources/SWDA-Prefpane/Resources/Info.plist.src" "$PREFPANE_PATH/Contents/Info.plist"

# Compile XIBs
echo "Compiling XIBs..."
for xib in Sources/SWDA-Prefpane/Resources/*.xib; do
    filename=$(basename "$xib" .xib)
    xcrun ibtool --errors --warnings --notices --output-format human-readable-text \
        --compile "$PREFPANE_PATH/Contents/Resources/$filename.nib" "$xib"
done

# Compile Assets
echo "Compiling Assets..."
xcrun actool --output-format human-readable-text --notices --warnings --platform macosx \
    --minimum-deployment-target 10.13 --target-device mac \
    --app-icon SwiftDefaultApps \
    --output-partial-info-plist Build/partial.plist \
    --compile "$PREFPANE_PATH/Contents/Resources" "Sources/SWDA-Prefpane/Resources/Assets.xcassets"

# Copy other resources
cp "Sources/SWDA-Prefpane/Resources/Unsupported.icns" "$PREFPANE_PATH/Contents/Resources/"

# Copy DummyApp into Prefpane Resources
cp -R "$DUMMY_APP_PATH" "$PREFPANE_PATH/Contents/Resources/"

# Copy CLI tool
cp "$BUILD_PATH/swda" "$PREFPANE_PATH/Contents/Resources/"

# Ad-hoc sign the bundle
echo "Signing bundle..."
codesign --force --deep --sign - "$PREFPANE_PATH"

echo "Build complete. Artifacts in Build/"
