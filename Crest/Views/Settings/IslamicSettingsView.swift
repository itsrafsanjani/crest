import SwiftUI

struct IslamicSettingsView: View {
    var locationService: LocationService
    var prayerTimeService: PrayerTimeService
    var notificationService: PrayerNotificationService

    @AppStorage(AppSettingsKey.islamicModeEnabled) private var islamicModeEnabled = AppSettingsDefault.islamicModeEnabled
    @AppStorage(AppSettingsKey.calculationMethod) private var calculationMethod = AppSettingsDefault.calculationMethod
    @AppStorage(AppSettingsKey.madhab) private var madhab = AppSettingsDefault.madhab
    @AppStorage(AppSettingsKey.hijriDateOffset) private var hijriDateOffset = AppSettingsDefault.hijriDateOffset
    @AppStorage(AppSettingsKey.showHijriInMenuBar) private var showHijriInMenuBar = AppSettingsDefault.showHijriInMenuBar
    @AppStorage(AppSettingsKey.prayerNotificationsEnabled) private var notificationsEnabled = AppSettingsDefault.prayerNotificationsEnabled
    @AppStorage(AppSettingsKey.overlayRespectDND) private var respectDND = AppSettingsDefault.overlayRespectDND

    @State private var adjustments: [String: Int] = AppSettingsDefault.defaultPrayerAdjustments
    @State private var notifPerPrayer: [String: Bool] = AppSettingsDefault.defaultPrayerNotificationPerPrayer
    @State private var adhanPerPrayer: [String: Bool] = AppSettingsDefault.defaultPrayerAdhanPerPrayer
    @State private var overlay1PerPrayer: [String: Bool] = AppSettingsDefault.defaultOverlay1PerPrayer
    @State private var overlay2PerPrayer: [String: Bool] = AppSettingsDefault.defaultOverlay2PerPrayer

    var body: some View {
        Form {
            Section {
                Toggle("Enable Islamic Mode", isOn: $islamicModeEnabled)
                    .onChange(of: islamicModeEnabled) { _, _ in
                        prayerTimeService.recompute()
                        notificationService.scheduleAll()
                    }
            }

            if islamicModeEnabled {
                locationSection
                calculationSection
                adjustmentsSection
                hijriSection
                notificationsSection
                overlaySection
            }
        }
        .formStyle(.grouped)
        .onAppear { loadPerPrayerSettings() }
    }

    // MARK: - Location

    private var locationSection: some View {
        Section("Location") {
            HStack {
                Text("Status")
                Spacer()
                Text(locationService.statusDescription)
                    .foregroundStyle(.secondary)
            }

            if let lat = locationService.latitude, let lon = locationService.longitude {
                HStack {
                    Text("Coordinates")
                    Spacer()
                    Text(String(format: "%.4f, %.4f", lat, lon))
                        .foregroundStyle(.secondary)
                        .font(.callout.monospacedDigit())
                }
            }

            Button("Refresh Location") {
                locationService.requestLocation()
            }
        }
    }

    // MARK: - Calculation

    private var calculationSection: some View {
        Section("Calculation") {
            Picker("Method", selection: $calculationMethod) {
                ForEach(CalculationMethodOption.allCases) { option in
                    Text(option.displayName).tag(option.rawValue)
                }
            }
            .onChange(of: calculationMethod) { _, _ in recomputeAndReschedule() }

            Picker("Madhab (Asr)", selection: $madhab) {
                ForEach(MadhabOption.allCases) { option in
                    Text(option.displayName).tag(option.rawValue)
                }
            }
            .onChange(of: madhab) { _, _ in recomputeAndReschedule() }
        }
    }

    // MARK: - Time Adjustments

    private var adjustmentsSection: some View {
        Section("Time Adjustments") {
            ForEach(Prayer.adjustable) { prayer in
                let binding = Binding<Int>(
                    get: { adjustments[prayer.rawValue] ?? 0 },
                    set: { newValue in
                        adjustments[prayer.rawValue] = newValue
                        saveAdjustments()
                    }
                )
                Stepper(
                    "\(prayer.displayName): \(signedMinutes(adjustments[prayer.rawValue] ?? 0))",
                    value: binding,
                    in: -30...30
                )
            }
        }
    }

    // MARK: - Hijri Date

    private var hijriSection: some View {
        Section("Hijri Date") {
            Stepper(
                "Date offset: \(signedDays(hijriDateOffset))",
                value: $hijriDateOffset,
                in: -3...3
            )
            .onChange(of: hijriDateOffset) { _, _ in prayerTimeService.recompute() }

            Toggle("Show Hijri date in menu bar", isOn: $showHijriInMenuBar)
        }
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Prayer notifications", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { _, newValue in
                    if newValue && !notificationService.isAuthorized {
                        notificationService.requestAuthorization()
                    }
                    notificationService.scheduleAll()
                }

            if notificationsEnabled {
                ForEach(Prayer.adjustable) { prayer in
                    HStack {
                        Toggle(prayer.displayName, isOn: prayerNotifBinding(prayer))

                        Spacer()

                        if Bundle.main.url(forResource: "adhan", withExtension: "caf") != nil {
                            Toggle("Adhan", isOn: adhanBinding(prayer))
                                .toggleStyle(.switch)
                                .labelsHidden()
                            Text("Adhan")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Overlay

    private var overlaySection: some View {
        Section("Prayer Reminders") {
            Toggle("Respect Do Not Disturb", isOn: $respectDND)

            ForEach(Prayer.adjustable) { prayer in
                VStack(alignment: .leading, spacing: 4) {
                    Text(prayer.displayName)
                        .font(.callout.weight(.medium))
                    HStack(spacing: 16) {
                        Toggle("Remind at start", isOn: overlay1Binding(prayer))
                            .toggleStyle(.checkbox)
                        Toggle("Remind before end", isOn: overlay2Binding(prayer))
                            .toggleStyle(.checkbox)
                    }
                    .font(.caption)
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Helpers

    private func signedMinutes(_ value: Int) -> String {
        value == 0 ? "0 min" : (value > 0 ? "+\(value) min" : "\(value) min")
    }

    private func signedDays(_ value: Int) -> String {
        value == 0 ? "0 days" : (value > 0 ? "+\(value) day\(value == 1 ? "" : "s")" : "\(value) day\(abs(value) == 1 ? "" : "s")")
    }

    private func recomputeAndReschedule() {
        prayerTimeService.recompute()
        notificationService.scheduleAll()
    }

    // MARK: - Per-prayer bindings

    private func prayerNotifBinding(_ prayer: Prayer) -> Binding<Bool> {
        Binding(
            get: { notifPerPrayer[prayer.rawValue] ?? true },
            set: { newValue in
                notifPerPrayer[prayer.rawValue] = newValue
                UserDefaults.standard.set(notifPerPrayer, forKey: AppSettingsKey.prayerNotificationPerPrayer)
                notificationService.scheduleAll()
            }
        )
    }

    private func adhanBinding(_ prayer: Prayer) -> Binding<Bool> {
        Binding(
            get: { adhanPerPrayer[prayer.rawValue] ?? false },
            set: { newValue in
                adhanPerPrayer[prayer.rawValue] = newValue
                UserDefaults.standard.set(adhanPerPrayer, forKey: AppSettingsKey.prayerAdhanPerPrayer)
                notificationService.scheduleAll()
            }
        )
    }

    private func overlay1Binding(_ prayer: Prayer) -> Binding<Bool> {
        Binding(
            get: { overlay1PerPrayer[prayer.rawValue] ?? true },
            set: { newValue in
                overlay1PerPrayer[prayer.rawValue] = newValue
                UserDefaults.standard.set(overlay1PerPrayer, forKey: AppSettingsKey.overlay1PerPrayer)
            }
        )
    }

    private func overlay2Binding(_ prayer: Prayer) -> Binding<Bool> {
        Binding(
            get: { overlay2PerPrayer[prayer.rawValue] ?? true },
            set: { newValue in
                overlay2PerPrayer[prayer.rawValue] = newValue
                UserDefaults.standard.set(overlay2PerPrayer, forKey: AppSettingsKey.overlay2PerPrayer)
            }
        )
    }

    // MARK: - Persistence

    private func loadPerPrayerSettings() {
        let defaults = UserDefaults.standard
        adjustments = (defaults.dictionary(forKey: AppSettingsKey.prayerAdjustments) as? [String: Int])
            ?? AppSettingsDefault.defaultPrayerAdjustments
        notifPerPrayer = (defaults.dictionary(forKey: AppSettingsKey.prayerNotificationPerPrayer) as? [String: Bool])
            ?? AppSettingsDefault.defaultPrayerNotificationPerPrayer
        adhanPerPrayer = (defaults.dictionary(forKey: AppSettingsKey.prayerAdhanPerPrayer) as? [String: Bool])
            ?? AppSettingsDefault.defaultPrayerAdhanPerPrayer
        overlay1PerPrayer = (defaults.dictionary(forKey: AppSettingsKey.overlay1PerPrayer) as? [String: Bool])
            ?? AppSettingsDefault.defaultOverlay1PerPrayer
        overlay2PerPrayer = (defaults.dictionary(forKey: AppSettingsKey.overlay2PerPrayer) as? [String: Bool])
            ?? AppSettingsDefault.defaultOverlay2PerPrayer
    }

    private func saveAdjustments() {
        UserDefaults.standard.set(adjustments, forKey: AppSettingsKey.prayerAdjustments)
        recomputeAndReschedule()
    }
}
