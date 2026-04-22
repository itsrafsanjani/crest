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
- **Testing tab must stay in sync.** Whenever a new alert type or sound is added, add a matching test button in `TestingSettingsView.swift`. Sound triggers go in the "Sounds" section; visual/window alerts go in the "Alerts" section. Sound trigger methods in services (e.g., `triggerTestAlert`) must call `AlertSoundService` if sound is enabled — never bypass the sound path when simulating a real alert.

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
| next    | v1.0  | Date calculator, polish, App Store                        |

## When Adding New Files

1. Create the `.swift` file in the appropriate directory under `Crest/`.
2. Run `xcodegen generate` to add it to the Xcode project.
3. Build with `xcodebuild` to verify.

No manual Xcode project editing required — xcodegen picks up files automatically from the `Crest/` source directory.
