import SwiftUI

struct PrayerOverlayView: View {
    let prayer: Prayer
    let prayerTime: Date
    let onDismiss: () -> Void
    let onSnooze: () -> Void

    @State private var remainingSeconds: Int
    @State private var dismissText = ""
    @State private var timer: Timer?
    @State private var selectedSnoozeDuration: Int = 5

    private let totalDuration: Int = 15 * 60

    init(prayer: Prayer, prayerTime: Date, onDismiss: @escaping () -> Void, onSnooze: @escaping () -> Void) {
        self.prayer = prayer
        self.prayerTime = prayerTime
        self.onDismiss = onDismiss
        self.onSnooze = onSnooze
        let remaining = Int(max(0, prayerTime.timeIntervalSince(Date())))
        _remainingSeconds = State(initialValue: remaining)
    }

    private var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return Double(remainingSeconds) / Double(totalDuration)
    }

    private var countdownText: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private var canDismiss: Bool {
        dismissText.lowercased().trimmingCharacters(in: .whitespaces) == "inshallah"
    }

    private var themeColor: Color { prayer.themeColor }

    var body: some View {
        ZStack {
            overlayBackground
            countdownBadge
            mainContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { startCountdown() }
        .onDisappear { timer?.invalidate() }
    }

    private var overlayBackground: some View {
        ZStack {
            Color.black

            RadialGradient(
                colors: [
                    themeColor.opacity(0.4),
                    themeColor.opacity(0.15),
                    Color.black.opacity(0.8)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 800
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var countdownBadge: some View {
        VStack {
            Text(countdownText)
                .font(.system(size: 14, weight: .medium, design: .rounded).monospacedDigit())
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: prayer.systemImage)
                .font(.system(size: 48))
                .foregroundStyle(themeColor)
                .padding(.bottom, 24)

            Text("It's time for \(prayer.displayName)")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 16)

            Text(quranVerse)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 500)
                .padding(.bottom, 32)

            progressBar
                .padding(.bottom, 40)

            dismissField
                .padding(.bottom, 32)

            actionButtons

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var progressBar: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.white.opacity(0.1))
                .frame(width: 300, height: 4)

            Capsule()
                .fill(themeColor)
                .frame(width: 300 * progress, height: 4)
                .animation(.linear(duration: 1), value: remainingSeconds)
        }
        .frame(width: 300, height: 4)
    }

    private var dismissField: some View {
        VStack(spacing: 8) {
            Text("Type **inshallah** to dismiss")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))

            TextField("", text: $dismissText)
                .textFieldStyle(.plain)
                .font(.body)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(width: 220)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                )
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Button(action: onSnooze) {
                    Label("Snooze (\(selectedSnoozeDuration)m)", systemImage: "moon.zzz")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(themeColor, in: Capsule())
                }
                .buttonStyle(.plain)

                Button(action: onDismiss) {
                    Label("Skip", systemImage: "xmark")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.1), in: Capsule())
                        .overlay(Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(!canDismiss)
                .opacity(canDismiss ? 1 : 0.4)
            }

            HStack(spacing: 8) {
                ForEach([5, 10, 15, 30], id: \.self) { duration in
                    Button {
                        selectedSnoozeDuration = duration
                    } label: {
                        Text("\(duration)m")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(selectedSnoozeDuration == duration ? .white : .white.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                selectedSnoozeDuration == duration ? themeColor.opacity(0.6) : .white.opacity(0.08),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var quranVerse: String {
        "\"Indeed, prayer has been decreed upon the believers a decree of specified times.\" (Surah An-Nisa 4:103)"
    }

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let remaining = Int(max(0, prayerTime.timeIntervalSince(Date())))
            remainingSeconds = remaining
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
}
