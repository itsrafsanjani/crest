import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var meetingAlertService: MeetingAlertService?
    var globalShortcutService: GlobalShortcutService?
    var prayerOverlayService: PrayerOverlayService?
    private(set) var prayerNotificationService: PrayerNotificationService?
    private var localKeyMonitor: Any?

    @discardableResult
    func setup(calendarService: CalendarService, prayerTimeService: PrayerTimeService) -> Bool {
        guard meetingAlertService == nil else { return false }

        let alertService = MeetingAlertService(calendarService: calendarService)
        meetingAlertService = alertService
        globalShortcutService = GlobalShortcutService(meetingAlertService: alertService)

        let notifService = PrayerNotificationService(prayerTimeService: prayerTimeService)
        prayerNotificationService = notifService
        prayerOverlayService = PrayerOverlayService(prayerTimeService: prayerTimeService)

        registerLocalShortcuts()
        return true
    }

    private func registerLocalShortcuts() {
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.modifierFlags.contains(.command) else { return event }
            switch event.charactersIgnoringModifiers {
            case ",":
                Self.openSettings()
                return nil
            case "q":
                NSApp.terminate(nil)
                return nil
            default:
                return event
            }
        }
    }

    static func openSettings() {
        if #available(macOS 14.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            for window in NSApp.windows where !window.title.isEmpty && window.title != "Item-0" {
                window.orderFrontRegardless()
            }
        }
    }
}
