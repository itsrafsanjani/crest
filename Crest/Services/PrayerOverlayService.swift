import Foundation
import Observation
import AppKit

@Observable
final class PrayerOverlayService {
    private let prayerTimeService: PrayerTimeService
    private var scheduledTimers: [String: Timer] = [:]
    private var dismissedPrayers: Set<String> = []
    private var refreshTimer: Timer?
    private(set) var overlayWindow: PrayerOverlayWindow?
    private(set) var activePrayer: Prayer?

    private let warningMinutes: TimeInterval = 15

    init(prayerTimeService: PrayerTimeService) {
        self.prayerTimeService = prayerTimeService
        startPeriodicRefresh()
        scheduleOverlays()
    }

    deinit {
        refreshTimer?.invalidate()
        scheduledTimers.values.forEach { $0.invalidate() }
    }

    func scheduleOverlays() {
        scheduledTimers.values.forEach { $0.invalidate() }
        scheduledTimers.removeAll()

        guard prayerTimeService.isEnabled else { return }

        let perPrayer = (UserDefaults.standard.dictionary(forKey: AppSettingsKey.overlay1PerPrayer) as? [String: Bool])
            ?? AppSettingsDefault.defaultOverlay1PerPrayer

        let now = Date()
        let warningInterval = warningMinutes * 60

        for prayerTime in prayerTimeService.todayPrayers {
            let prayer = prayerTime.prayer
            guard prayer != .sunrise else { continue }
            guard perPrayer[prayer.rawValue] ?? true else { continue }
            guard !dismissedPrayers.contains(prayer.rawValue) else { continue }

            let fireTime = prayerTime.time.addingTimeInterval(-warningInterval)
            guard fireTime > now else { continue }

            let delay = fireTime.timeIntervalSince(now)
            let timer = Timer.scheduledTimer(withTimeInterval: max(delay, 0.1), repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fireOverlay(for: prayer, prayerTime: prayerTime.time)
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            scheduledTimers[prayer.rawValue] = timer
        }
    }

    func dismissOverlay() {
        if let prayer = activePrayer {
            dismissedPrayers.insert(prayer.rawValue)
        }
        overlayWindow?.close()
        overlayWindow = nil
        activePrayer = nil
    }

    func snoozeOverlay() {
        guard let prayer = activePrayer else { return }
        overlayWindow?.close()
        overlayWindow = nil
        activePrayer = nil

        let snoozeTimer = Timer.scheduledTimer(withTimeInterval: 5 * 60, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { return }
                if let pt = self.prayerTimeService.timeForPrayer(prayer) {
                    self.fireOverlay(for: prayer, prayerTime: pt)
                }
            }
        }
        RunLoop.main.add(snoozeTimer, forMode: .common)
        scheduledTimers["\(prayer.rawValue)-snooze"] = snoozeTimer
    }

    // MARK: - Private

    private func fireOverlay(for prayer: Prayer, prayerTime: Date) {
        guard prayerTimeService.isEnabled else { return }
        guard !dismissedPrayers.contains(prayer.rawValue) else { return }

        let respectDND = UserDefaults.standard.object(forKey: AppSettingsKey.overlayRespectDND) as? Bool
            ?? AppSettingsDefault.overlayRespectDND
        if respectDND {
            // Skip if DND/Focus is active — NSDoNotDisturbEnabled is the legacy key
            if let dndEnabled = UserDefaults(suiteName: "com.apple.notificationcenterui")?.bool(forKey: "doNotDisturb"),
               dndEnabled {
                return
            }
        }

        showOverlayWindow(prayer: prayer, prayerTime: prayerTime)
        scheduledTimers.removeValue(forKey: prayer.rawValue)
    }

    private func showOverlayWindow(prayer: Prayer, prayerTime: Date) {
        dismissOverlayWindowOnly()

        activePrayer = prayer
        let window = PrayerOverlayWindow(
            prayer: prayer,
            prayerTime: prayerTime,
            onDismiss: { [weak self] in self?.dismissOverlay() },
            onSnooze: { [weak self] in self?.snoozeOverlay() }
        )
        overlayWindow = window
        window.showFullscreen()
    }

    private func dismissOverlayWindowOnly() {
        overlayWindow?.close()
        overlayWindow = nil
    }

    private func startPeriodicRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.cleanupDismissed()
                self?.scheduleOverlays()
            }
        }
        RunLoop.main.add(refreshTimer!, forMode: .common)
    }

    private func cleanupDismissed() {
        let now = Date()
        var toRemove: [String] = []
        for key in dismissedPrayers {
            guard let prayer = Prayer(rawValue: key),
                  let time = prayerTimeService.timeForPrayer(prayer) else {
                toRemove.append(key)
                continue
            }
            // Clear dismissed state after the prayer time has passed
            if time < now {
                toRemove.append(key)
            }
        }
        toRemove.forEach { dismissedPrayers.remove($0) }
    }
}
