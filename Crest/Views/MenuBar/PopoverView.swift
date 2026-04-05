import SwiftUI
import AppKit

struct PopoverView: View {
    var clock: ClockService
    var calendarService: CalendarService
    var prayerTimeService: PrayerTimeService

    @AppStorage(AppSettingsKey.islamicModeEnabled) private var islamicModeEnabled = AppSettingsDefault.islamicModeEnabled

    @Environment(\.openSettings) private var openSettingsAction

    @State private var selectedDate: Date? = nil

    private var showPrayers: Bool {
        islamicModeEnabled && !prayerTimeService.todayPrayers.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            MiniCalendarView(
                calendarService: calendarService,
                selectedDate: $selectedDate,
                hijriDateString: islamicModeEnabled ? prayerTimeService.hijriDateString : nil
            )

            Divider()

            EventListView(
                calendarService: calendarService,
                selectedDate: selectedDate
            )

            if showPrayers {
                Divider()
                PrayerTimesView(prayerTimeService: prayerTimeService)
            }

            Divider()

            footer
        }
        .frame(width: 320)
        .background(.regularMaterial)
    }

    private var footer: some View {
        HStack {
            Button {
                openSettings()
            } label: {
                Image(systemName: "gear")
                    .font(.callout)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("Settings ⌘,")

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.callout)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("Quit ⌘Q")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
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
}
