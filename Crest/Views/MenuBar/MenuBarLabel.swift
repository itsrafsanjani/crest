import SwiftUI

struct MenuBarLabel: View {
    @AppStorage(AppSettingsKey.dateFormat) private var dateFormat = AppSettingsDefault.dateFormat
    @AppStorage(AppSettingsKey.showSeconds) private var showSeconds = AppSettingsDefault.showSeconds
    @AppStorage(AppSettingsKey.showUpcomingEventInMenuBar) private var showEvent = AppSettingsDefault.showUpcomingEventInMenuBar
    @AppStorage(AppSettingsKey.menuBarEventMaxLength) private var maxEventLength = AppSettingsDefault.menuBarEventMaxLength

    var clock: ClockService
    var nextEventTitle: String?

    var body: some View {
        let timeText = clock.formattedTime(format: dateFormat, showSeconds: showSeconds)
        let eventText = truncatedEvent

        HStack(spacing: 6) {
            Text(timeText)
            if let eventText {
                Text("·")
                    .foregroundStyle(.secondary)
                Text(eventText)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var truncatedEvent: String? {
        guard showEvent, let title = nextEventTitle, !title.isEmpty else { return nil }
        if title.count <= maxEventLength { return title }
        return String(title.prefix(maxEventLength - 1)) + "…"
    }
}
