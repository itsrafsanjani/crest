# Crest — Agent Guide

## What is Crest

A native macOS menu bar app (no Dock icon) for calendar events, meetings, and schedule awareness. Optional Islamic Mode adds prayer times. See `.agents/plans/SRD.md` for the full spec.

## Tech Stack

- **Language:** Swift 5.9, macOS 14.0+ deployment target
- **UI:** SwiftUI with `MenuBarExtra` (`.window` style) + AppKit where needed
- **State:** `@Observable` (Observation framework), `@AppStorage` for persistence
- **Calendar:** EventKit (`EKEventStore`) — reads system calendars including synced Google Calendar
- **Build system:** Xcode 16.1 project generated via `xcodegen` from `project.yml`

## Build & Run

All builds use the CLI — no Xcode GUI required.

```bash
# 1. Generate .xcodeproj (required after adding/removing files or changing project.yml)
xcodegen generate

# 2. Build (ad-hoc signed for local development without an Apple Developer team)
xcodebuild -project Crest.xcodeproj -scheme Crest -configuration Debug build \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=YES

# 3. Kill any running instance, then launch
killall Crest 2>/dev/null; sleep 1
open $(xcodebuild -project Crest.xcodeproj -scheme Crest -configuration Debug \
  -showBuildSettings 2>/dev/null | grep -m1 'BUILT_PRODUCTS_DIR' | awk '{print $3}')/Crest.app
```

### Granting Calendar Permission (first launch)

The app requires calendar access. On first launch:

1. Click the Crest date/time label in the menu bar and click **"Grant Access"** in the popover, or
2. Open **System Settings > Privacy & Security > Calendars** and enable Crest manually:

   ```bash
   open "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
   ```

3. Restart the app after granting permission (`killall Crest`, then relaunch).

### Code Signing Notes

- The project uses ad-hoc signing (`CODE_SIGN_IDENTITY="-"`) for local development.
- No Apple Developer team is required for building and testing locally.
- For App Store distribution (v1.0), switch to `CODE_SIGN_STYLE: Automatic` with a valid development team in `project.yml`.

## Key Conventions

- **No Xcode GUI.** All project config lives in `project.yml`. Run `xcodegen generate` to regenerate `Crest.xcodeproj` after any structural change (new files, targets, build settings).
- **`@Observable` over `ObservableObject`.** Use the Observation framework for all service/state classes.
- **No `init()` on `CrestApp`.** SwiftUI recreates the `App` struct multiple times. Background services (timers, event monitors) must be initialized in `AppDelegate` via `@NSApplicationDelegateAdaptor`, not in `CrestApp.init()`.
- **Settings keys** are centralized in `AppSettingsKey` / `AppSettingsDefault` enums in `AppSettings.swift`. Always add new settings there.
- **No dock icon.** `LSUIElement = true` in Info.plist — the app lives entirely in the menu bar.
- **Entitlements** are in `Crest.entitlements`. Add new capabilities there (e.g., reminders, location).
- **Meeting link patterns** go in `MeetingLinkDetector.patterns` array.

## Testing Prayer Overlays

Overlay 1 is scheduled at `prayerTime - 15 minutes` and Overlay 2 is scheduled near prayer end, so real-world testing can be delayed by hours. Use the built-in manual triggers in Settings for immediate verification.

### Preconditions

1. Enable **Islamic Mode**.
2. Set **Respect Do Not Disturb** as desired (when enabled and Focus/DND is active, overlays will be suppressed).

### Trigger Steps

1. Open settings (`Cmd+,`).
2. Go to **Islamic Mode** tab.
3. In **Prayer Reminders**, click **Test Overlay 1 Now** or **Test Overlay 2 Now**.

### Expected Behavior

1. The selected overlay appears immediately in fullscreen.
2. Overlay 1 shows start-time reminder content and supports **Snooze 5 min**.
3. Overlay 2 shows before-end reminder content for the active/next prayer window.
4. **Dismiss** closes the overlay.

## Release Phases

| Current | Phase | Scope                                                                   |
| ------- | ----- | ----------------------------------------------------------------------- |
| done    | v0.1  | Menu bar shell, clock label, settings skeleton                          |
| done    | v0.2  | EventKit, calendar popover, event list                                  |
| done    | v0.3  | Meeting detection (50+ services), join button, fullscreen meeting alert |
| done    | v0.4  | Islamic Mode: prayer times, Hijri date, notifications, Overlay 1        |
| done    | v0.5  | Overlay 2 (prayer ending alert), prayer tracking, sleep/wake            |
| next    | v1.0  | World clocks, date calculator, polish, App Store                        |

## When Adding New Files

1. Create the `.swift` file in the appropriate directory under `Crest/`.
2. Run `xcodegen generate` to add it to the Xcode project.
3. Build with `xcodebuild` to verify.

No manual Xcode project editing required — xcodegen picks up files automatically from the `Crest/` source directory.

## Cursor Cloud specific instructions

This is a **native macOS app** (SwiftUI + AppKit). The Cloud VM runs Ubuntu Linux, so `xcodebuild` and the full macOS SDK are unavailable. The following tools **do** work on Linux and are pre-installed by the update script:

| Tool | Command | What it covers |
|---|---|---|
| **Swift (6.3)** | `swift -frontend -parse <file>.swift` | Syntax-only parsing (no type-checking — macOS frameworks are absent) |
| **SwiftLint** | `swiftlint-static lint` | Linting (uses the statically-linked binary; the dynamic `swiftlint` requires SourceKit) |
| **XcodeGen** | `LOGNAME="${LOGNAME:-ubuntu}" xcodegen generate` | Project generation from `project.yml` |

### Gotchas

- **`LOGNAME` must be set** for `xcodegen generate` to succeed. The update script adds `export LOGNAME="${LOGNAME:-ubuntu}"` to `~/.bashrc`, but if you run xcodegen in a non-login shell, pass it inline.
- **Full builds (`xcodebuild`) cannot run on Linux.** Building and running the app requires macOS with Xcode 16.1+. Use the syntax parse + SwiftLint workflow above to validate changes.
- **`swiftlint` (dynamic) crashes** on this VM due to missing `libsourcekitdInProc.so`. Always use `swiftlint-static` instead.
- The `.swift-version` file created by `swiftly` in the workspace root is git-ignored and cleaned up by the update script to avoid interfering with the repo.

### Typical validation workflow

```bash
# 1. Lint
swiftlint-static lint

# 2. Syntax-check all files
find Crest -name '*.swift' -print0 | xargs -0 swift -frontend -parse

# 3. Regenerate Xcode project (after adding/removing files or changing project.yml)
LOGNAME="${LOGNAME:-ubuntu}" xcodegen generate
```
