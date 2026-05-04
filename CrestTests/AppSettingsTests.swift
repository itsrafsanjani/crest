import XCTest
@testable import Crest

final class AppSettingsTests: XCTestCase {

    // MARK: - Per-prayer dictionary shape

    /// Every per-prayer setting must cover all five canonical prayer names.
    /// If a new prayer is ever added (or one is dropped), this test forces an explicit decision.
    func test_perPrayerDictionariesCoverAllFivePrayers() {
        let expected: Set<String> = ["fajr", "dhuhr", "asr", "maghrib", "isha"]

        XCTAssertEqual(Set(AppSettingsDefault.defaultPrayerAdjustments.keys), expected)
        XCTAssertEqual(Set(AppSettingsDefault.defaultPrayerNotificationPerPrayer.keys), expected)
        XCTAssertEqual(Set(AppSettingsDefault.defaultPrayerAdhanPerPrayer.keys), expected)
        XCTAssertEqual(Set(AppSettingsDefault.defaultOverlay1PerPrayer.keys), expected)
        XCTAssertEqual(Set(AppSettingsDefault.defaultOverlay2PerPrayer.keys), expected)
        XCTAssertEqual(Set(AppSettingsDefault.defaultJamaatTimes.keys), expected)
    }

    func test_jamaatTimesAreValid24HourStrings() {
        for (prayer, time) in AppSettingsDefault.defaultJamaatTimes {
            let parts = time.split(separator: ":")
            XCTAssertEqual(parts.count, 2, "Jamaat time for \(prayer) should be HH:mm — got \(time)")
            guard parts.count == 2,
                  let hour = Int(parts[0]),
                  let minute = Int(parts[1]) else {
                XCTFail("Could not parse \(time) for \(prayer)")
                continue
            }
            XCTAssertTrue((0...23).contains(hour), "Hour out of range for \(prayer): \(hour)")
            XCTAssertTrue((0...59).contains(minute), "Minute out of range for \(prayer): \(minute)")
        }
    }

    func test_dateFormatDefaultIsValidOption() {
        XCTAssertNotNil(DateFormatOption(rawValue: AppSettingsDefault.dateFormat))
    }

    // MARK: - UserDefaults round-trip

    func test_userDefaultsRoundTripBoolKey() {
        let defaults = UserDefaults.standard
        let key = AppSettingsKey.islamicModeEnabled
        let original = defaults.object(forKey: key)
        defer { defaults.set(original, forKey: key) }

        defaults.set(true, forKey: key)
        XCTAssertEqual(defaults.object(forKey: key) as? Bool, true)

        defaults.set(false, forKey: key)
        XCTAssertEqual(defaults.object(forKey: key) as? Bool, false)
    }

    func test_userDefaultsRoundTripStringKey() {
        let defaults = UserDefaults.standard
        let key = AppSettingsKey.calculationMethod
        let original = defaults.object(forKey: key)
        defer { defaults.set(original, forKey: key) }

        defaults.set("moonsightingCommittee", forKey: key)
        XCTAssertEqual(defaults.string(forKey: key), "moonsightingCommittee")
    }

    func test_userDefaultsRoundTripDictionaryKey() {
        let defaults = UserDefaults.standard
        let key = AppSettingsKey.jamaatTimes
        let original = defaults.dictionary(forKey: key)
        defer { defaults.set(original, forKey: key) }

        let expected: [String: String] = [
            "fajr": "05:30",
            "dhuhr": "13:30",
            "asr": "17:30",
            "maghrib": "18:45",
            "isha": "20:00"
        ]
        defaults.set(expected, forKey: key)
        let read = defaults.dictionary(forKey: key) as? [String: String]
        XCTAssertEqual(read, expected)
    }
}
