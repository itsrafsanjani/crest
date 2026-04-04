import SwiftUI

struct SettingsView: View {
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

            PlaceholderSettingsView(
                title: "Islamic Mode",
                description: "Prayer times, Hijri date, and overlay settings will appear here."
            )
            .tabItem {
                Label("Islamic Mode", systemImage: "moon.stars")
            }
        }
        .frame(width: 480, height: 320)
    }
}
