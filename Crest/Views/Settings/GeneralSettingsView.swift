import SwiftUI
import ServiceManagement

struct GeneralSettingsView: View {
    @AppStorage(AppSettingsKey.dateFormat) private var dateFormat = AppSettingsDefault.dateFormat
    @AppStorage(AppSettingsKey.showSeconds) private var showSeconds = AppSettingsDefault.showSeconds
    @AppStorage(AppSettingsKey.showUpcomingEventInMenuBar) private var showUpcomingEvent = AppSettingsDefault.showUpcomingEventInMenuBar
    @AppStorage(AppSettingsKey.menuBarEventMaxLength) private var menuBarEventMaxLength = AppSettingsDefault.menuBarEventMaxLength

    @AppStorage(AppSettingsKey.meetingAlertEnabled) private var meetingAlertEnabled = AppSettingsDefault.meetingAlertEnabled
    @AppStorage(AppSettingsKey.joinMeetingShortcutEnabled) private var joinShortcutEnabled = AppSettingsDefault.joinMeetingShortcutEnabled

    @State private var launchAtLogin = false

    var body: some View {
        Form {
            Section("Menu Bar Clock") {
                Picker("Date & Time Format", selection: $dateFormat) {
                    ForEach(DateFormatOption.allCases) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }

                Toggle("Show seconds", isOn: $showSeconds)
            }

            Section("Upcoming Event") {
                Toggle("Show next event in menu bar", isOn: $showUpcomingEvent)

                if showUpcomingEvent {
                    Stepper(
                        "Max title length: \(menuBarEventMaxLength)",
                        value: $menuBarEventMaxLength,
                        in: 10...60,
                        step: 5
                    )
                }
            }

            Section("Meetings") {
                Toggle("Fullscreen alert when meetings start", isOn: $meetingAlertEnabled)

                Toggle("Global shortcut to join next meeting", isOn: $joinShortcutEnabled)
                if joinShortcutEnabled {
                    HStack {
                        Text("Shortcut")
                        Spacer()
                        Text("⌘⇧J")
                            .font(.body.monospaced())
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
                    }
                }
            }

            Section("System") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(newValue)
                    }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
