import SwiftUI

@main
struct CrestApp: App {
    @State private var clock = ClockService()
    @State private var calendarService = CalendarService()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(clock: clock, calendarService: calendarService)
        } label: {
            MenuBarLabel(
                clock: clock,
                nextEventTitle: calendarService.nextEvent?.title
            )
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
        }
    }
}
