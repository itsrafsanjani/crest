import SwiftUI

@main
struct CrestApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var clock = ClockService()
    @State private var calendarService = CalendarService()

    var body: some Scene {
        let _ = appDelegate.setup(calendarService: calendarService)

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
