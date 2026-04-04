import SwiftUI
import AppKit

struct PopoverView: View {
    var clock: ClockService
    var calendarService: CalendarService
    var prayerTimeService: PrayerTimeService

    @AppStorage(AppSettingsKey.dateFormat) private var dateFormat = AppSettingsDefault.dateFormat
    @AppStorage(AppSettingsKey.showSeconds) private var showSeconds = AppSettingsDefault.showSeconds
    @AppStorage(AppSettingsKey.islamicModeEnabled) private var islamicModeEnabled = AppSettingsDefault.islamicModeEnabled

    @Environment(\.openSettings) private var openSettingsAction

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
            if islamicModeEnabled && !prayerTimeService.todayPrayers.isEmpty {
                Divider()
                PrayerTimesView(prayerTimeService: prayerTimeService)
            }
            Divider()
            footer
        }
        .frame(width: 320, height: islamicModeEnabled && !prayerTimeService.todayPrayers.isEmpty ? 630 : 550)
    }

    private var header: some View {
        VStack(spacing: 2) {
            Text(clock.formattedTime(format: dateFormat, showSeconds: showSeconds))
                .font(.system(size: 28, weight: .light, design: .rounded))
                .monospacedDigit()
            Text(headerDate)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if islamicModeEnabled && !prayerTimeService.hijriDateString.isEmpty {
                Text(prayerTimeService.hijriDateString)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
    }

    private var footer: some View {
        HStack {
            Button {
                openSettings()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "gear")
                    Text("Settings")
                    Text("⌘,")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .font(.callout)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "power")
                    Text("Quit")
                    Text("⌘Q")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .font(.callout)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func openSettings() {
        openSettingsAction()
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            for window in NSApp.windows where !window.title.isEmpty && window.title != "Item-0" {
                window.orderFrontRegardless()
            }
        }
    }

    private var headerDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: clock.currentTime)
    }
}
