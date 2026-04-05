import SwiftUI

struct PrayerEndingOverlayView: View {
    let prayer: Prayer
    let prayerEndTime: Date
    let nextPrayer: Prayer?
    let nextPrayerStartTime: Date?
    let onDismiss: () -> Void

    @State private var remainingSeconds: Int
    @State private var dismissText = ""
    @State private var timer: Timer?

    private let totalDuration: Int = 20 * 60

    init(prayer: Prayer, prayerEndTime: Date,
         nextPrayer: Prayer?, nextPrayerStartTime: Date?,
         onDismiss: @escaping () -> Void) {
        self.prayer = prayer
        self.prayerEndTime = prayerEndTime
        self.nextPrayer = nextPrayer
        self.nextPrayerStartTime = nextPrayerStartTime
        self.onDismiss = onDismiss
        let remaining = Int(max(0, prayerEndTime.timeIntervalSince(Date())))
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

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    private var urgencyColor: Color {
        Color(red: 0.85, green: 0.25, blue: 0.15)
    }

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
                    urgencyColor.opacity(0.5),
                    prayer.themeColor.opacity(0.2),
                    Color.black.opacity(0.85)
                ],
                center: .center,
                startRadius: 80,
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
                .foregroundStyle(urgencyColor)
                .padding(.bottom, 24)

            Text(remainingSeconds > 0 ? "\(prayer.displayName) Ending Soon" : "\(prayer.displayName) Time Has Ended")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 16)

            Text("\"Verily, the prayer is enjoined on the believers at fixed hours.\" (Surah An-Nisa 4:103)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 500)
                .padding(.bottom, 20)

            if let next = nextPrayer, let startTime = nextPrayerStartTime {
                HStack(spacing: 6) {
                    Image(systemName: next.systemImage)
                        .font(.caption)
                    Text("\(next.displayName) begins at \(Self.timeFormatter.string(from: startTime))")
                        .font(.callout)
                }
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.white.opacity(0.08), in: Capsule())
                .padding(.bottom, 20)
            }

            progressBar
                .padding(.bottom, 40)

            dismissField
                .padding(.bottom, 32)

            Button(action: onDismiss) {
                Text("Dismiss")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(urgencyColor, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!canDismiss)
            .opacity(canDismiss ? 1 : 0.4)

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
                .fill(urgencyColor)
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

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let remaining = Int(max(0, prayerEndTime.timeIntervalSince(Date())))
            remainingSeconds = remaining
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
}
