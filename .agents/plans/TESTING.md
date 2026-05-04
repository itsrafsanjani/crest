# TESTING — automated + manual QA

## Why we test like this

The project shipped to v0.5 with **no automated tests**. Recent client-reported bugs cluster in three areas:

- **Prayer overlay timing** — snooze duration, jamaat reschedule, overlay window calculations
- **Calendar rendering** — popover layout shift, event list edge cases
- **Notification/alert timing** — meeting alerts, current-prayer highlighting

This guide closes the loop: **automated unit tests** for pure logic, **manual QA checklist** for UI / system-integration surfaces, and a **release smoke test** to run before tagging.

**Rule:** when you fix a client-reported bug, add a regression test. The test target is the receipt that the fix is durable.

---

## 1. Automated tests (XCTest)

### Run the suite

```bash
xcodebuild test -project Crest.xcodeproj -scheme Crest \
  -destination 'platform=macOS' \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO
```

### What's covered today

| Test file                          | Surface                              | Notes                                                                 |
| ---------------------------------- | ------------------------------------ | --------------------------------------------------------------------- |
| `MeetingLinkDetectorTests.swift`   | Regex patterns, generic-URL fallback | One assertion per major service + non-meeting URLs return `nil`       |
| `PrayerTimeServiceTests.swift`     | Adhan integration, recompute output  | Integration smoke test using a static location fixture (Dhaka coords) |
| `AppSettingsTests.swift`           | Keys/defaults coherence              | Round-trips `UserDefaults`, asserts every per-prayer dict has 5 keys  |

### What's intentionally NOT covered

- **SwiftUI views** — no snapshot or UI tests yet. Use the manual checklist (Section 3).
- **`EKEventStore`, `NSSound`, `AVAudioPlayer`, `CLLocationManager`** — system integrations, not worth mocking in v1.
- **Overlay scheduling timers** (`PrayerOverlayService`, `PrayerEndingOverlayService`) — wall-clock dependent. Use the in-app **Test Overlay 1/2 Now** buttons instead.
- **Sleep/wake transitions** — test manually by locking the Mac.

### Adding a test

1. Drop a `*Tests.swift` file under `CrestTests/`.
2. Run `xcodegen generate` so it gets picked up by the test target.
3. Run `xcodebuild test ...` to verify.

### CI

Not yet wired. When adding `.github/workflows/test.yml`, mirror the local command above and target macOS-14 runners.

---

## 2. In-app manual triggers (Settings → Testing tab)

`Crest/Views/Settings/TestingSettingsView.swift` exposes immediate triggers for everything that's normally time-gated. Use these for fast iteration on prayer overlays and meeting alerts.

### Preconditions

1. Calendar permission granted (see `BUILD.md`).
2. **Islamic Mode** enabled (Settings → Islamic Mode) for prayer triggers.
3. **Respect Do Not Disturb** toggle set as desired — when ON and Focus is active, overlays will be suppressed (and that's a valid test case).

### Triggers

Open Settings (`Cmd+,`) → **Testing** tab.

**Sounds section:**

- **Test Meeting Alert Sound** — plays the meeting-alert tone via `AlertSoundService`.
- **Test Prayer Overlay Sound** — plays the prayer-overlay tone via `AlertSoundService`.

**Alerts section:**

- **Test Meeting Alert** — fires `MeetingAlertService.triggerTestAlert()`.
- **Test Overlay 1 Now** — fires `PrayerOverlayService.triggerOverlay1TestNow()` (start-of-prayer overlay).
- **Test Overlay 2 Now** — fires `PrayerEndingOverlayService.triggerOverlay2TestNow()` (end-of-prayer-window overlay).
- **Test Jamaat Alert** — fires the jamaat path (currently shares Overlay 1 trigger).

Each button shows a pass/fail indicator after firing.

### Convention to preserve

When you add a new alert type or sound, add a matching button to `TestingSettingsView` and route its trigger method through `AlertSoundService` if sound is enabled. **Never** bypass the sound path when simulating a real alert — that creates a divergence between manual tests and production behavior, which is exactly how regressions slip in.

---

## 3. Manual QA checklist (run for any surface you touch)

Tick every item that applies to your change. Each scenario lists the surface, what to do, and what to verify.

### Menu bar

- [ ] **Clock label** updates each minute; respects the configured `dateFormat`.
- [ ] **Click** opens the calendar popover.
- [ ] **No Dock icon** — `LSUIElement = true`. App is invisible in Dock and Cmd-Tab.

### Calendar popover

- [ ] Always renders **6 rows** (no layout shift on month change). Regression from `7bb28aa`.
- [ ] Today is highlighted.
- [ ] Month navigation arrows work; clicking a date updates the events list below.
- [ ] All-day events render distinctly from timed events.

### Events list

- [ ] Time range matches the `calendarLookaheadDays` setting.
- [ ] Events with meeting links show a **Join** affordance.
- [ ] Declined events are hidden when `showDeclinedEvents` is off.

### Meeting alerts

- [ ] Alert fires `meetingAlertOffsetMinutes` before the meeting (default 1 min).
- [ ] Alert window appears fullscreen on the active display.
- [ ] **Join** opens the correct URL in the default handler.
- [ ] Sound plays only when `meetingAlertSoundEnabled` is true.
- [ ] When DND is active and **Respect DND** is on, alert is suppressed.

### Prayer times (Islamic Mode)

- [ ] Hijri date label is correct (apply `hijriDateOffset` for verification).
- [ ] All 5 prayers + sunrise are listed for today, in order.
- [ ] **Current prayer** is highlighted with **time remaining** (not next prayer). Regression from `b22feb8`.
- [ ] After the last prayer of the day passes, highlight rolls forward to tomorrow's Fajr.

### Overlay 1 (prayer start)

- [ ] **Test Overlay 1 Now** displays the overlay immediately.
- [ ] Overlay shows the start-time reminder content.
- [ ] **Snooze** respects the user-selected duration (5 / 10 / 15 min). Regression from `df3b3d6`.
- [ ] Waqt-end countdown is visible during the overlay. From `d09325b`.
- [ ] **Dismiss** closes the overlay.

### Overlay 2 (prayer ending)

- [ ] **Test Overlay 2 Now** displays the end-of-window overlay.
- [ ] Content references the active/next prayer window correctly.
- [ ] **Dismiss** closes the overlay.

### Jamaat alert

- [ ] Explicit jamaat times (24-hour `HH:mm`) are honored. From `0f6754e`.
- [ ] Changing jamaat settings while the app runs **reschedules** timers — alerts fire at the new time without app restart. Regression from `2380d29`.

### Sounds

- [ ] **Test Meeting Alert Sound** plays when sound is enabled, silent when disabled.
- [ ] **Test Prayer Overlay Sound** same behavior.
- [ ] Real alert paths (not just test buttons) route through `AlertSoundService`.

### Sleep / wake

- [ ] Lock the Mac and wait through a scheduled overlay window. On unlock, pending alerts catch up via `SleepWakeService` and fire (or are correctly suppressed if the window has fully passed).
- [ ] Day rollover at midnight while asleep — `lastComputedDay` triggers a `recompute()` and tomorrow's prayers load correctly.

### Do Not Disturb / Focus

- [ ] Enable a Focus mode. With **Respect DND** ON, overlays do not appear.
- [ ] With **Respect DND** OFF, overlays appear regardless of Focus.

### First launch

- [ ] Revoke calendar permission in System Settings, relaunch — popover shows **Grant Access**.
- [ ] After granting + restart, events load.

### Settings persistence

- [ ] Change every setting on every tab.
- [ ] `killall Crest`, relaunch.
- [ ] All values are retained (uses `@AppStorage` → `UserDefaults`).

---

## 4. Release smoke test (pre-tag checklist)

Abridged 10-step pass before tagging a release:

1. `xcodegen generate` — clean output.
2. `xcodebuild build` — compiles without warnings introduced this cycle.
3. `xcodebuild test` — all green.
4. Launch the app cold. Calendar popover opens, events load.
5. Trigger **Test Meeting Alert** — alert + sound + Join button work.
6. Enable Islamic Mode, set static location. Prayer times appear.
7. Trigger **Test Overlay 1 Now** with snooze=10min. Snooze re-fires after 10min (or use a shorter window for verification).
8. Trigger **Test Overlay 2 Now**. Dismisses cleanly.
9. Toggle Focus on, repeat steps 5/7 with **Respect DND** ON — alerts suppressed.
10. `killall Crest`, relaunch — settings persisted, prayer times still correct.

If any step fails, do not tag.
