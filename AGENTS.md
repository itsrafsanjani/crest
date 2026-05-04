# Crest — Agent Guide

A native macOS menu bar app (no Dock icon) for calendar events, meetings, and prayer times. See `.agents/plans/SRD.md` for the full spec.

## Tech stack

- **Language:** Swift 5.9, macOS 14.0+ deployment target
- **UI:** SwiftUI with `MenuBarExtra` (`.window` style) + AppKit where needed
- **State:** `@Observable` (Observation framework), `@AppStorage` for persistence
- **Calendar:** EventKit (`EKEventStore`) — reads system calendars including synced Google Calendar
- **Prayer math:** [Adhan](https://github.com/batoulapps/adhan-swift) (SPM)
- **Auto-update:** [Sparkle](https://github.com/sparkle-project/Sparkle) 2.9.x (SPM)
- **Build system:** Xcode 16.1 project generated via `xcodegen` from `project.yml`

## Build & run

```bash
xcodegen generate
xcodebuild -project Crest.xcodeproj -scheme Crest -configuration Debug build \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=YES
killall Crest 2>/dev/null; sleep 1
open $(xcodebuild -project Crest.xcodeproj -scheme Crest -configuration Debug \
  -showBuildSettings 2>/dev/null | grep -m1 'BUILT_PRODUCTS_DIR' | awk '{print $3}')/Crest.app
```

Run tests:

```bash
xcodebuild test -project Crest.xcodeproj -scheme Crest \
  -destination 'platform=macOS' \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO
```

> Plain `xcodebuild test` will fail with `requires that the name of a scheme … be provided` — you must pass `-project`, `-scheme Crest`, and `-destination 'platform=macOS'`. The code-signing overrides keep tests running without a developer cert.

First-launch calendar permission flow, code signing, and release-build notes live in `.agents/plans/BUILD.md`.

## Skills available in this repo

- **`swiftui-expert-skill`** — at `.agents/skills/swiftui-expert-skill/SKILL.md`. Consult its `references/` (latest-apis, animation, state, macOS, performance, accessibility) for any non-trivial SwiftUI work — new views, refactors, performance, macOS-specific APIs.

## Key conventions

- **No Xcode GUI.** All project config lives in `project.yml`. Run `xcodegen generate` after any structural change (new files, targets, build settings).
- **`@Observable` over `ObservableObject`.** Use the Observation framework for all service/state classes.
- **No `init()` on `CrestApp`.** SwiftUI recreates the `App` struct multiple times. Background services (timers, event monitors) must be initialized in `AppDelegate` via `@NSApplicationDelegateAdaptor`, not in `CrestApp.init()`.
- **Settings keys** are centralized in `AppSettingsKey` / `AppSettingsDefault` enums in `Crest/Models/AppSettings.swift`. Always add new settings there.
- **No dock icon.** `LSUIElement = true` in Info.plist — the app lives entirely in the menu bar.
- **Entitlements** are in `Crest/Crest.entitlements`. Add new capabilities there (e.g., reminders, location).
- **Meeting link patterns** go in `MeetingLinkDetector.patterns` array.
- **TestingSettingsView parity.** Whenever a new alert type or sound is added, add a matching test button in `Crest/Views/Settings/TestingSettingsView.swift`. Sound triggers go in the "Sounds" section; visual/window alerts go in the "Alerts" section. Sound trigger methods in services (e.g., `triggerTestAlert`) must call `AlertSoundService` if sound is enabled — never bypass the sound path when simulating a real alert.
- **Add a regression test when you fix a client-reported bug.** Drop it under `CrestTests/` so the fix can't silently regress. See `.agents/plans/TESTING.md`.

## Testing

The project has historically had **no automated tests**, and recent client-reported bugs cluster in prayer overlays, calendar rendering, and notification timing. Treat testing as load-bearing:

1. **Run the test suite before any PR:**

   ```bash
   xcodebuild test -project Crest.xcodeproj -scheme Crest \
     -destination 'platform=macOS' \
     CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO
   ```

   The `CrestTests` target covers `MeetingLinkDetector`, `PrayerTimeService` integration, and `AppSettings` shape.
2. **Walk the manual QA checklist** in `.agents/plans/TESTING.md` for any surface you touched (calendar, meeting alerts, prayer overlays, sounds, sleep/wake, DND).
3. **Use the Testing tab** in Settings (`Cmd+,`) for immediate overlay/sound triggers — Overlay 1 / Overlay 2 / Jamaat / Meeting Alert.

## When adding new files

1. Create the `.swift` file under `Crest/` (or `CrestTests/` for tests).
2. Run `xcodegen generate` to add it to the Xcode project.
3. Build with `xcodebuild` to verify.

xcodegen picks up files automatically from the source directories — no manual Xcode project editing.

## Pointers

- Spec / requirements: `.agents/plans/SRD.md`
- Roadmap & release phases: `.agents/plans/ROADMAP.md`
- Build & code-signing detail: `.agents/plans/BUILD.md`
- Manual QA + XCTest guide: `.agents/plans/TESTING.md`
