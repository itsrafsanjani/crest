import SwiftUI
import ServiceManagement
import Sparkle

struct GeneralSettingsView: View {
    var onTestMeetingAlertNow: (() -> Bool)?
    var updater: SPUUpdater

    @AppStorage(AppSettingsKey.meetingAlertEnabled) private var meetingAlertEnabled = AppSettingsDefault.meetingAlertEnabled
    @AppStorage(AppSettingsKey.joinMeetingShortcutEnabled) private var joinShortcutEnabled = AppSettingsDefault.joinMeetingShortcutEnabled

    @State private var launchAtLogin = false
    @State private var meetingTestStatus: String?

    var body: some View {
        Form {
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

                Button("Test Meeting Alert Now") {
                    let didTrigger = onTestMeetingAlertNow?() ?? false
                    meetingTestStatus = didTrigger ? "Meeting alert test triggered." : "Unable to trigger meeting alert."
                }

                if let meetingTestStatus {
                    Text(meetingTestStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("System") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(newValue)
                    }
            }

            Section("Updates") {
                Button("Check for Updates…") {
                    updater.checkForUpdates()
                }
                .disabled(!updater.canCheckForUpdates)
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
