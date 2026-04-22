import SwiftUI
import Sparkle

struct SettingsView: View {
    var updater: SPUUpdater
    var locationService: LocationService
    var prayerTimeService: PrayerTimeService
    var notificationService: PrayerNotificationService?
    var onTestOverlay1Now: (() -> Bool)?
    var onTestOverlay2Now: (() -> Bool)?
    var onTestMeetingAlertNow: (() -> Bool)?
    var onTestJamaatAlertNow: (() -> Bool)?

    var body: some View {
        TabView {
            GeneralSettingsView(updater: updater)
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            CalendarSettingsView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            if let notifService = notificationService {
                IslamicSettingsView(
                    locationService: locationService,
                    prayerTimeService: prayerTimeService,
                    notificationService: notifService
                )
                .tabItem {
                    Label("Islamic Mode", systemImage: "moon.stars")
                }
            } else {
                PlaceholderSettingsView(
                    title: "Islamic Mode",
                    description: "Prayer times, Hijri date, and overlay settings will appear here."
                )
                .tabItem {
                    Label("Islamic Mode", systemImage: "moon.stars")
                }
            }

            TestingSettingsView(
                onTestMeetingAlertNow: onTestMeetingAlertNow,
                onTestOverlay1Now: onTestOverlay1Now,
                onTestOverlay2Now: onTestOverlay2Now,
                onTestJamaatAlertNow: onTestJamaatAlertNow
            )
            .tabItem {
                Label("Testing", systemImage: "flask")
            }
        }
        .frame(width: 480, height: 420)
    }
}
