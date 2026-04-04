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

```bash
# Generate .xcodeproj (required after adding/removing files or changing project.yml)
xcodegen generate

# Build
xcodebuild -project Crest.xcodeproj -scheme Crest -configuration Debug build

# Run (find the app in DerivedData)
open $(xcodebuild -project Crest.xcodeproj -scheme Crest -configuration Debug -showBuildSettings 2>/dev/null | grep -m1 'BUILT_PRODUCTS_DIR' | awk '{print $3}')/Crest.app
```

## Key Conventions

- **No Xcode GUI.** All project config lives in `project.yml`. Run `xcodegen generate` to regenerate `Crest.xcodeproj` after any structural change (new files, targets, build settings).
- **`@Observable` over `ObservableObject`.** Use the Observation framework for all service/state classes.
- **Settings keys** are centralized in `AppSettingsKey` / `AppSettingsDefault` enums in `AppSettings.swift`. Always add new settings there.
- **No dock icon.** `LSUIElement = true` in Info.plist — the app lives entirely in the menu bar.
- **Entitlements** are in `Crest.entitlements`. Add new capabilities there (e.g., reminders, location).
- **Meeting link patterns** go in `MeetingLinkDetector.patterns` array.

## Release Phases

| Current | Phase | Scope |
|---------|-------|-------|
| done | v0.1 | Menu bar shell, clock label, settings skeleton |
| done | v0.2 | EventKit, calendar popover, event list |
| next | v0.3 | Meeting detection (50+ services), join button, fullscreen meeting alert |
| | v0.4 | Islamic Mode: prayer times, Hijri date, notifications, Overlay 1 |
| | v0.5 | Overlay 2 (prayer ending alert), prayer tracking, sleep/wake |
| | v1.0 | World clocks, date calculator, polish, App Store |

## When Adding New Files

1. Create the `.swift` file in the appropriate directory under `Crest/`.
2. Run `xcodegen generate` to add it to the Xcode project.
3. Build with `xcodebuild` to verify.

No manual Xcode project editing required — xcodegen picks up files automatically from the `Crest/` source directory.
