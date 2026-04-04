import SwiftUI

enum DateFormatOption: String, CaseIterable, Identifiable {
    case short = "h:mm a"
    case medium = "h:mm:ss a"
    case long = "EEE h:mm a"
    case full = "EEE, MMM d  h:mm a"
    case iso = "yyyy-MM-dd HH:mm"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .short: return "12:30 PM"
        case .medium: return "12:30:45 PM"
        case .long: return "Sat 12:30 PM"
        case .full: return "Sat, Apr 4  12:30 PM"
        case .iso: return "2026-04-04 12:30"
        }
    }
}

enum AppSettingsKey {
    static let dateFormat = "dateFormat"
    static let showSeconds = "showSeconds"
    static let showUpcomingEventInMenuBar = "showUpcomingEventInMenuBar"
    static let menuBarEventMaxLength = "menuBarEventMaxLength"
    static let calendarLookaheadDays = "calendarLookaheadDays"
    static let showDeclinedEvents = "showDeclinedEvents"
    static let enabledCalendarIDs = "enabledCalendarIDs"
    static let islamicModeEnabled = "islamicModeEnabled"
    static let meetingAlertEnabled = "meetingAlertEnabled"
    static let joinMeetingShortcutEnabled = "joinMeetingShortcutEnabled"

    // Islamic Mode
    static let calculationMethod = "calculationMethod"
    static let madhab = "madhab"
    static let prayerAdjustments = "prayerAdjustments"
    static let hijriDateOffset = "hijriDateOffset"
    static let showHijriInMenuBar = "showHijriInMenuBar"
    static let prayerNotificationsEnabled = "prayerNotificationsEnabled"
    static let prayerNotificationPerPrayer = "prayerNotificationPerPrayer"
    static let prayerAdhanPerPrayer = "prayerAdhanPerPrayer"
    static let overlay1PerPrayer = "overlay1PerPrayer"
    static let overlay2PerPrayer = "overlay2PerPrayer"
    static let overlayRespectDND = "overlayRespectDND"
    static let cachedLatitude = "cachedLatitude"
    static let cachedLongitude = "cachedLongitude"
}

enum AppSettingsDefault {
    static let dateFormat = DateFormatOption.full.rawValue
    static let showSeconds = false
    static let showUpcomingEventInMenuBar = true
    static let menuBarEventMaxLength = 30
    static let calendarLookaheadDays = 7
    static let showDeclinedEvents = false
    static let islamicModeEnabled = false
    static let meetingAlertEnabled = true
    static let joinMeetingShortcutEnabled = true

    // Islamic Mode
    static let calculationMethod = "moonsightingCommittee"
    static let madhab = "shafi"
    static let hijriDateOffset = 0
    static let showHijriInMenuBar = false
    static let prayerNotificationsEnabled = true
    static let overlayRespectDND = true

    static let defaultPrayerAdjustments: [String: Int] = [
        "fajr": 0, "dhuhr": 0, "asr": 0, "maghrib": 0, "isha": 0
    ]
    static let defaultPrayerNotificationPerPrayer: [String: Bool] = [
        "fajr": true, "dhuhr": true, "asr": true, "maghrib": true, "isha": true
    ]
    static let defaultPrayerAdhanPerPrayer: [String: Bool] = [
        "fajr": false, "dhuhr": false, "asr": false, "maghrib": false, "isha": false
    ]
    static let defaultOverlay1PerPrayer: [String: Bool] = [
        "fajr": true, "dhuhr": true, "asr": true, "maghrib": true, "isha": true
    ]
    static let defaultOverlay2PerPrayer: [String: Bool] = [
        "fajr": true, "dhuhr": true, "asr": true, "maghrib": true, "isha": true
    ]
}
