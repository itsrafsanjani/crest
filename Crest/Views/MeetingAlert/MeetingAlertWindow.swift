import AppKit
import SwiftUI
import EventKit

enum MeetingAlertAction {
    case join
    case dismiss
}

final class MeetingAlertWindow: NSPanel {
    private let onAction: (MeetingAlertAction) -> Void

    init(event: EKEvent, meetingLink: MeetingLink, onAction: @escaping (MeetingAlertAction) -> Void) {
        self.onAction = onAction

        let screen = NSScreen.main ?? NSScreen.screens[0]
        let frame = screen.frame

        super.init(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.level = .screenSaver
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovable = false
        self.isMovableByWindowBackground = false
        self.hidesOnDeactivate = false

        let alertView = MeetingAlertView(
            eventTitle: event.title ?? "Untitled Event",
            timeRange: DateFormatting.eventTimeRange(
                start: event.startDate,
                end: event.endDate,
                isAllDay: event.isAllDay
            ),
            calendarName: event.calendar.title,
            calendarColor: Color(cgColor: event.calendar.cgColor),
            serviceName: meetingLink.service.rawValue,
            attendees: (event.attendees ?? []).compactMap { $0.name ?? $0.url.absoluteString },
            onJoin: { onAction(.join) },
            onDismiss: { onAction(.dismiss) }
        )

        let hostingView = NSHostingView(rootView: alertView)
        hostingView.frame = frame
        self.contentView = hostingView
    }

    func showFullscreen() {
        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Esc
            onAction(.dismiss)
        } else {
            super.keyDown(with: event)
        }
    }

    override var canBecomeKey: Bool { true }
}
