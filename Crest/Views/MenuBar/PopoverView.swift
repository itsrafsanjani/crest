import SwiftUI

struct PopoverView: View {
    var clock: ClockService
    var calendarService: CalendarService

    @AppStorage(AppSettingsKey.dateFormat) private var dateFormat = AppSettingsDefault.dateFormat
    @AppStorage(AppSettingsKey.showSeconds) private var showSeconds = AppSettingsDefault.showSeconds

    @State private var selectedDate: Date? = nil

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            MiniCalendarView(
                calendarService: calendarService,
                selectedDate: $selectedDate
            )
            Divider()
            EventListView(
                calendarService: calendarService,
                selectedDate: selectedDate
            )
        }
        .frame(width: 320, height: 520)
    }

    private var header: some View {
        VStack(spacing: 2) {
            Text(clock.formattedTime(format: dateFormat, showSeconds: showSeconds))
                .font(.system(size: 28, weight: .light, design: .rounded))
                .monospacedDigit()
            Text(headerDate)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
    }

    private var headerDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: clock.currentTime)
    }
}
