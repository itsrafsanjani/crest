import EventKit
import Observation
import AppKit

@Observable
final class MeetingAlertService {
    private let calendarService: CalendarService
    private var scheduledTimers: [String: Timer] = [:]
    private var dismissedEventIDs: Set<String> = []
    private var refreshTimer: Timer?
    private(set) var alertWindow: MeetingAlertWindow?

    var isAlertEnabled: Bool {
        UserDefaults.standard.object(forKey: AppSettingsKey.meetingAlertEnabled) as? Bool
            ?? AppSettingsDefault.meetingAlertEnabled
    }

    init(calendarService: CalendarService) {
        self.calendarService = calendarService
        startPeriodicRefresh()
        scheduleAlerts()
    }

    deinit {
        refreshTimer?.invalidate()
        scheduledTimers.values.forEach { $0.invalidate() }
    }

    func nextMeetingLink() -> (event: EKEvent, link: MeetingLink)? {
        let now = Date()
        for event in calendarService.events {
            guard !event.isAllDay, event.startDate > now || event.endDate > now else { continue }
            if let link = MeetingLinkDetector.detect(
                location: event.location,
                notes: event.notes,
                url: event.url
            ) {
                return (event, link)
            }
        }
        return nil
    }

    func scheduleAlerts() {
        scheduledTimers.values.forEach { $0.invalidate() }
        scheduledTimers.removeAll()

        guard isAlertEnabled else { return }

        let now = Date()
        let horizon = now.addingTimeInterval(30 * 60)

        for event in calendarService.events {
            guard !event.isAllDay,
                  event.startDate > now,
                  event.startDate <= horizon,
                  !dismissedEventIDs.contains(event.eventIdentifier)
            else { continue }

            guard MeetingLinkDetector.detect(
                location: event.location,
                notes: event.notes,
                url: event.url
            ) != nil else { continue }

            let interval = event.startDate.timeIntervalSince(now)
            let timer = Timer.scheduledTimer(withTimeInterval: max(interval, 0.1), repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fireMeetingAlert(for: event)
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            scheduledTimers[event.eventIdentifier] = timer
        }
    }

    @discardableResult
    func triggerTestAlert() -> Bool {
        let now = Date()
        let startDate = now.addingTimeInterval(5 * 60)
        let endDate = now.addingTimeInterval(35 * 60)
        let timeRange = DateFormatting.eventTimeRange(start: startDate, end: endDate, isAllDay: false)

        dismissAlert()

        let window = MeetingAlertWindow(
            title: "Test Meeting",
            startDate: startDate,
            timeRange: timeRange,
            serviceName: "Test"
        ) { [weak self] action in
            switch action {
            case .join, .dismiss:
                self?.dismissAlert()
            case .snooze:
                self?.dismissAlert()
            }
        }
        alertWindow = window
        window.showFullscreen()
        return true
    }

    func dismissAlert(for eventID: String? = nil) {
        if let eventID {
            dismissedEventIDs.insert(eventID)
        }
        alertWindow?.close()
        alertWindow = nil
    }

    private func fireMeetingAlert(for event: EKEvent) {
        guard isAlertEnabled,
              !dismissedEventIDs.contains(event.eventIdentifier)
        else { return }

        guard let link = MeetingLinkDetector.detect(
            location: event.location,
            notes: event.notes,
            url: event.url
        ) else { return }

        showAlertWindow(event: event, meetingLink: link)
        scheduledTimers.removeValue(forKey: event.eventIdentifier)
    }

    private func showAlertWindow(event: EKEvent, meetingLink: MeetingLink) {
        dismissAlert()

        let window = MeetingAlertWindow(event: event, meetingLink: meetingLink) { [weak self] action in
            switch action {
            case .join:
                NSWorkspace.shared.open(meetingLink.url)
                self?.dismissAlert(for: event.eventIdentifier)
            case .dismiss:
                self?.dismissAlert(for: event.eventIdentifier)
            case .snooze(let minutes):
                self?.snoozeAlert(event: event, meetingLink: meetingLink, minutes: minutes)
            }
        }
        alertWindow = window
        window.showFullscreen()
    }

    private func snoozeAlert(event: EKEvent, meetingLink: MeetingLink, minutes: Int) {
        alertWindow?.close()
        alertWindow = nil
        let delay = TimeInterval(minutes * 60)
        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showAlertWindow(event: event, meetingLink: meetingLink)
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        scheduledTimers["snooze_\(event.eventIdentifier ?? "unknown")"] = timer
    }

    private func startPeriodicRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.cleanupDismissedEvents()
                self?.scheduleAlerts()
            }
        }
        RunLoop.main.add(refreshTimer!, forMode: .common)
    }

    private func cleanupDismissedEvents() {
        let now = Date()
        let activeIDs = Set(calendarService.events.filter { $0.endDate > now }.compactMap(\.eventIdentifier))
        dismissedEventIDs = dismissedEventIDs.filter { activeIDs.contains($0) }
    }
}
