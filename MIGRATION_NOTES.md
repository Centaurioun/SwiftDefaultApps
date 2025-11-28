# Migration and Fixes Report (November 2025)

This document details the steps taken to restore functionality to the `SwiftDefaultApps` repository. The project had become unbuildable due to outdated dependencies, API changes in libraries, and Swift language evolution.

## 1. Dependency Issues (SwiftCLI)

### The Problem
The project originally depended on `SwiftCLI` version `2.0.3`. This version is extremely old and no longer compatible with modern Swift tools. When trying to build, the package manager could not resolve the dependency.

### The Fix
1.  We switched the dependency to a forked version of `SwiftCLI` hosted at `https://github.com/Centaurioun/SwiftCLI`.
2.  We updated `Package.swift` to point to the `master` branch of this fork.

## 2. Major Code Refactoring (SwiftCLI API Update)

### The Problem
The `SwiftCLI` library has undergone massive changes between version 2.x and the current version. The old code used a "Registry" pattern that no longer exists.
-   **Old Way:** Classes inherited from `OptionCommand`, and options were added manually in a `setupOptions` function.
-   **New Way:** Classes inherit from `Command`, and options are defined using `@Key` and `@Flag` property wrappers (a modern Swift feature).

### The Fix
We rewrote all command files in `Sources/CLI Components/` (`getApps.swift`, `getHandler.swift`, `setHandler.swift`, etc.) to use the new API.

**Example of the change:**

*Old Code (Broken):*
```swift
class SetCommand: OptionCommand {
    func setupOptions(options: OptionRegistry) {
        options.add(flags: ["--internet"], usage: "...") { ... }
    }
}
```

*New Code (Fixed):*
```swift
class SetCommand: Command {
    @Flag("--internet", description: "...")
    var internet: Bool

    func execute() throws {
        if internet { ... }
    }
}
```

## 3. Visibility and Access Control

### The Problem
Swift projects are often split into "Targets" (modules). In this project, we have:
1.  `SWDA-Common` (Helper functions)
2.  `SWDA-CLI` (The command line tool)
3.  `SWDA-Prefpane` (The Settings UI)

By default, code in one module is `internal`, meaning other modules can't see it. The CLI and Prefpane targets were trying to use functions from `SWDA-Common`, but they were hidden.

### The Fix
1.  We added the `public` keyword to important classes and functions in `SWDA-Common` (like `LSWrappers`, `LSErrors`, and helper functions).
2.  We added `import SWDA_Common` to the top of files in the CLI and Prefpane targets so they can access these helpers.

## 4. Build Configuration (Linker Errors)

### The Problem
The build failed with "duplicate symbol `_main`". This happens when you try to combine two programs that both think they are the "main" program.
The `Package.swift` file incorrectly listed `DummyApp` (which is a standalone app) as a dependency for the CLI and Prefpane.

### The Fix
We removed `DummyApp` from the `dependencies` list of `SWDA-CLI` and `SWDA-Prefpane` in `Package.swift`.

## 5. Circular Dependencies

### The Problem
`SWDA-Common` is supposed to be a base layer that doesn't know about the specific UI code in `SWDA-Prefpane`. However, some extensions in `commonFuncs.swift` were trying to use types defined only in the Prefpane (like `SourceListRoleTypes` or `ControllersRef`). This created a loop: Common needs Prefpane, but Prefpane needs Common.

### The Fix
We moved the specific code that caused the loop out of `SWDA-Common` and into the Prefpane source files where it belongs:
-   Moved `extension NSControl` (UI code) to `Subclasses.swift`.
-   Moved `extension LSRolesMask` (UI data mapping) to `SWDAHandlersModel.swift`.

## 6. Cleanup of Legacy Artifacts

### The Problem
The repository contained a `Packages/` folder with an old copy of `SwiftCLI-2.0.3`. This was likely a leftover from an older package management strategy (vendoring dependencies).

### The Fix
We deleted the `Packages/` folder. The project now relies entirely on Swift Package Manager to fetch the correct version of `SwiftCLI` (from your fork) into the `.build/` directory. This keeps the repository clean and ensures we are using the version specified in `Package.swift`.

## How to Build and Run

To build the Command Line Interface (CLI):
```bash
swift build
```

To run the CLI from the terminal:
```bash
.build/debug/CLI --help
```

## 7. Full Project Modernization (SPM & Build Script)

### The Problem
The project relied on legacy `.xcodeproj` files that were broken and referenced deleted files. The folder structure was non-standard, and there was no easy way to build the final `.prefpane` bundle from the command line.

### The Fix
1.  **Removed Legacy Files**: Deleted all `.xcodeproj` and `.xcworkspace` files.
2.  **Restructured Folders**: Moved source code into standard SPM directories (`Sources/SWDA-CLI`, `Sources/SWDA-Prefpane`, etc.).
3.  **Updated Configuration**: Rewrote `Package.swift` to support resources and define correct targets (Library for Prefpane, Executable for CLI).
4.  **Created Build Script**: Added `build.sh` to automate the entire build process, including compiling XIBs/Assets and packaging the `.prefpane` and `.app` bundles.

### New Build Process
Simply run `./build.sh` to build everything. The output will be in the `Build/` folder.
