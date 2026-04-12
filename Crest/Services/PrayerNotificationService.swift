import Foundation
import UserNotifications
import Observation

@Observable
final class PrayerNotificationService {
    private let prayerTimeService: PrayerTimeService
    private var refreshTimer: Timer?
    private var lastScheduledDay: Int = -1

    private(set) var isAuthorized = false

    init(prayerTimeService: PrayerTimeService) {
        self.prayerTimeService = prayerTimeService
        checkAuthorization()
        scheduleAll()
        startDailyRefresh()
    }

    deinit {
        refreshTimer?.invalidate()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if granted { self?.scheduleAll() }
            }
        }
    }

    func scheduleAll() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard prayerTimeService.isEnabled else { return }

        let now = Date()

        let prayerNotifEnabled = UserDefaults.standard.object(forKey: AppSettingsKey.prayerNotificationsEnabled) as? Bool
            ?? AppSettingsDefault.prayerNotificationsEnabled

        if prayerNotifEnabled {
            let perPrayer = (UserDefaults.standard.dictionary(forKey: AppSettingsKey.prayerNotificationPerPrayer) as? [String: Bool])
                ?? AppSettingsDefault.defaultPrayerNotificationPerPrayer
            let perAdhan = (UserDefaults.standard.dictionary(forKey: AppSettingsKey.prayerAdhanPerPrayer) as? [String: Bool])
                ?? AppSettingsDefault.defaultPrayerAdhanPerPrayer

            for prayerTime in prayerTimeService.todayPrayers {
                let prayer = prayerTime.prayer
                guard prayer != .sunrise else { continue }
                guard perPrayer[prayer.rawValue] ?? true else { continue }
                guard prayerTime.time > now else { continue }

                let content = UNMutableNotificationContent()
                content.title = "\(prayer.displayName) Prayer"
                content.body = "It's time for \(prayer.displayName) (\(prayer.arabicName))"

                let useAdhan = perAdhan[prayer.rawValue] ?? false
                if useAdhan, let adhanURL = Bundle.main.url(forResource: "adhan", withExtension: "caf") {
                    if let attachment = try? UNNotificationAttachment(identifier: "adhan-\(prayer.rawValue)", url: adhanURL) {
                        content.attachments = [attachment]
                    }
                } else {
                    content.sound = .default
                }

                let interval = prayerTime.time.timeIntervalSince(now)
                guard interval > 0 else { continue }

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "prayer-\(prayer.rawValue)",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }
        }

        lastScheduledDay = Calendar.current.component(.day, from: Date())
    }

    // MARK: - Private

    private func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    private func startDailyRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self else { return }
            let today = Calendar.current.component(.day, from: Date())
            if today != self.lastScheduledDay {
                self.scheduleAll()
            }
        }
        RunLoop.main.add(refreshTimer!, forMode: .common)
    }
}
