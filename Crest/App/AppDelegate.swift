import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var meetingAlertService: MeetingAlertService?
    var globalShortcutService: GlobalShortcutService?

    @discardableResult
    func setup(calendarService: CalendarService) -> Bool {
        guard meetingAlertService == nil else { return false }
        let alertService = MeetingAlertService(calendarService: calendarService)
        meetingAlertService = alertService
        globalShortcutService = GlobalShortcutService(meetingAlertService: alertService)
        return true
    }
}
