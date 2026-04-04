import Foundation
import Observation
import Adhan

@Observable
final class PrayerTimeService {
    private let locationService: LocationService
    private var timer: Timer?
    private var lastComputedDay: Int = -1

    private(set) var todayPrayers: [PrayerTime] = []
    private(set) var currentPrayer: Prayer?
    private(set) var nextPrayer: Prayer?
    private(set) var nextPrayerTime: Date?
    private(set) var countdownToNext: TimeInterval = 0
    private(set) var hijriDateString: String = ""

    var isEnabled: Bool {
        UserDefaults.standard.object(forKey: AppSettingsKey.islamicModeEnabled) as? Bool
            ?? AppSettingsDefault.islamicModeEnabled
    }

    init(locationService: LocationService) {
        self.locationService = locationService
        recompute()
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func recompute() {
        guard isEnabled, let coords = locationService.coordinates else {
            todayPrayers = []
            currentPrayer = nil
            nextPrayer = nil
            nextPrayerTime = nil
            countdownToNext = 0
            hijriDateString = ""
            return
        }

        let methodRaw = UserDefaults.standard.string(forKey: AppSettingsKey.calculationMethod)
            ?? AppSettingsDefault.calculationMethod
        let madhabRaw = UserDefaults.standard.string(forKey: AppSettingsKey.madhab)
            ?? AppSettingsDefault.madhab

        let method = CalculationMethodOption(rawValue: methodRaw) ?? .moonsightingCommittee
        let madhab = MadhabOption(rawValue: madhabRaw) ?? .shafi

        var params = method.adhanMethod.params
        params.madhab = madhab.adhanMadhab

        let adjustments = loadAdjustments()
        params.adjustments.fajr = adjustments["fajr"] ?? 0
        params.adjustments.dhuhr = adjustments["dhuhr"] ?? 0
        params.adjustments.asr = adjustments["asr"] ?? 0
        params.adjustments.maghrib = adjustments["maghrib"] ?? 0
        params.adjustments.isha = adjustments["isha"] ?? 0

        let cal = Calendar(identifier: .gregorian)
        let dateComponents = cal.dateComponents([.year, .month, .day], from: Date())

        guard let prayers = PrayerTimes(coordinates: coords, date: dateComponents, calculationParameters: params) else {
            todayPrayers = []
            return
        }

        todayPrayers = [
            PrayerTime(prayer: .fajr, time: prayers.fajr),
            PrayerTime(prayer: .sunrise, time: prayers.sunrise),
            PrayerTime(prayer: .dhuhr, time: prayers.dhuhr),
            PrayerTime(prayer: .asr, time: prayers.asr),
            PrayerTime(prayer: .maghrib, time: prayers.maghrib),
            PrayerTime(prayer: .isha, time: prayers.isha),
        ]

        lastComputedDay = dateComponents.day ?? -1
        updateCurrentNext()
        computeHijriDate()
    }

    func timeForPrayer(_ prayer: Prayer) -> Date? {
        todayPrayers.first(where: { $0.prayer == prayer })?.time
    }

    // MARK: - Private

    private func updateCurrentNext() {
        let now = Date()

        var current: Prayer?
        var next: Prayer?

        let ordered: [Prayer] = [.fajr, .sunrise, .dhuhr, .asr, .maghrib, .isha]
        for (index, prayer) in ordered.enumerated() {
            guard let time = timeForPrayer(prayer) else { continue }
            if time <= now {
                current = prayer
                if index + 1 < ordered.count {
                    next = ordered[index + 1]
                }
            }
        }

        if current == nil {
            next = .fajr
        }

        currentPrayer = current
        nextPrayer = next

        if let next, let time = timeForPrayer(next) {
            nextPrayerTime = time
            countdownToNext = max(0, time.timeIntervalSince(now))
        } else {
            nextPrayerTime = nil
            countdownToNext = 0
        }
    }

    private func computeHijriDate() {
        let offset = UserDefaults.standard.integer(forKey: AppSettingsKey.hijriDateOffset)
        let adjustedDate = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()

        let hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
        let components = hijriCalendar.dateComponents([.year, .month, .day], from: adjustedDate)

        let formatter = DateFormatter()
        formatter.calendar = hijriCalendar
        formatter.dateStyle = .long

        let monthNames = [
            1: "Muharram", 2: "Safar", 3: "Rabi al-Awwal", 4: "Rabi al-Thani",
            5: "Jumada al-Ula", 6: "Jumada al-Thani", 7: "Rajab", 8: "Sha'ban",
            9: "Ramadan", 10: "Shawwal", 11: "Dhul Qi'dah", 12: "Dhul Hijjah"
        ]

        if let day = components.day, let month = components.month, let year = components.year {
            let monthName = monthNames[month] ?? "Unknown"
            hijriDateString = "\(day) \(monthName) \(year) AH"
        } else {
            hijriDateString = formatter.string(from: adjustedDate)
        }
    }

    private func loadAdjustments() -> [String: Int] {
        (UserDefaults.standard.dictionary(forKey: AppSettingsKey.prayerAdjustments) as? [String: Int])
            ?? AppSettingsDefault.defaultPrayerAdjustments
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.updateCurrentNext()

            let cal = Calendar(identifier: .gregorian)
            let today = cal.component(.day, from: Date())
            if today != self.lastComputedDay {
                self.recompute()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func formattedCountdown() -> String {
        let total = Int(countdownToNext)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
