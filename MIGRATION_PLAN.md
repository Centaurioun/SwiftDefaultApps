# Modernization and Migration Plan

This plan outlines the steps to fully modernize the `SwiftDefaultApps` project by removing legacy Xcode project files and relying on the Swift Package Manager (SPM) and a build script for creating the final distribution artifacts (`.prefpane` and `.app` bundles).

## Phase 1: Cleanup
1.  **Delete Legacy Project Files**: Remove the following directories which are no longer needed for an SPM-based workflow:
    *   `SwiftDefaultApps.xcworkspace`
    *   `SwiftDefaultApps CLI.xcodeproj`
    *   `SWDA Prefpane.xcodeproj`
    *   `AppDoesNothing.xcodeproj`

## Phase 2: Restructuring
2.  **Standardize Folder Structure**: Move source files to match the standard Swift Package Manager convention (`Sources/<TargetName>`).
    *   Rename `Sources/CLI Components` -> `Sources/SWDA-CLI`
    *   Rename `Sources/Prefpane Sources` -> `Sources/SWDA-Prefpane`
    *   Rename `Sources/Common Sources` -> `Sources/SWDA-Common`
    *   (Keep `Sources/DummyApp` as is)
3.  **Organize Resources**: Move resource files (Info.plist, .xib, .xcassets) into the corresponding source directories (e.g., `Sources/SWDA-Prefpane/Resources`).

## Phase 3: Configuration
4.  **Update `Package.swift`**:
    *   Update target definitions to reflect the new folder structure (removing custom `path` arguments).
    *   Explicitly declare resources (XIBs, Assets) for each target using the `resources` parameter.
    *   Change `SWDA-Prefpane` product type to a dynamic library (since it is loaded by System Preferences, not run as a standalone executable).

## Phase 4: Build Automation
5.  **Create `build.sh` Script**: Since SPM builds binaries but does not automatically create macOS bundles (like `.prefpane` or `.app` with the necessary `Info.plist` and compiled resources), we will create a shell script to:
    *   Run `swift build -c release`.
    *   Compile XIB files using `ibtool`.
    *   Create the `SwiftDefaultApps.prefpane` bundle structure and copy the binary and resources into it.
    *   Create the `DummyApp.app` bundle structure and copy the binary and resources into it.

## Phase 5: Documentation
6.  **Update Documentation**:
    *   Update `MIGRATION_NOTES.md` with a log of these changes.
    *   Update `README.md` with instructions on how to build the project using the new script.

## Outcome
After this migration, the project will be clean, contain only source code and build configuration (no opaque project files), and can be built from the command line with a single command.
