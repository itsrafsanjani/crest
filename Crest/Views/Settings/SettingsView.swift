import SwiftUI

struct SettingsView: View {
    var locationService: LocationService
    var prayerTimeService: PrayerTimeService
    var notificationService: PrayerNotificationService?
    var onTestOverlay1Now: (() -> Bool)?
    var onTestOverlay2Now: (() -> Bool)?

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            CalendarSettingsView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            PlaceholderSettingsView(
                title: "Appearance",
                description: "Theme and display customization options will appear here."
            )
            .tabItem {
                Label("Appearance", systemImage: "paintbrush")
            }

            PlaceholderSettingsView(
                title: "World Clocks",
                description: "Add and manage world clocks here."
            )
            .tabItem {
                Label("World Clocks", systemImage: "globe")
            }

            if let notifService = notificationService {
                IslamicSettingsView(
                    locationService: locationService,
                    prayerTimeService: prayerTimeService,
                    notificationService: notifService,
                    onTestOverlay1Now: onTestOverlay1Now,
                    onTestOverlay2Now: onTestOverlay2Now
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
        }
        .frame(width: 480, height: 420)
    }
}
