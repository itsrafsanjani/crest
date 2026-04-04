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

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                alertCard
                Spacer()
            }
        }
        .onAppear { startCountdown() }
        .onDisappear { timer?.invalidate() }
    }

    private var alertCard: some View {
        VStack(spacing: 28) {
            countdownRing
            prayerInfo
            nextPrayerInfo
            dismissField
            actions
        }
        .padding(40)
        .frame(width: 440)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(amberColor.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 40, y: 10)
    }

    private var countdownRing: some View {
        ZStack {
            Circle()
                .stroke(amberColor.opacity(0.15), lineWidth: 6)
                .frame(width: 120, height: 120)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    amberColor,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: remainingSeconds)

            VStack(spacing: 2) {
                Text(countdownText)
                    .font(.system(size: 28, weight: .light, design: .rounded).monospacedDigit())
                Text("remaining")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var prayerInfo: some View {
        VStack(spacing: 8) {
            Text(prayer.arabicName)
                .font(.system(size: 36, weight: .regular, design: .serif))

            Text(prayer.transliteration)
                .font(.title2.weight(.semibold))

            Text(remainingSeconds > 0 ? "Prayer time ending soon" : "Prayer time has ended")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(amberColor)
                .textCase(.uppercase)
                .tracking(0.8)
        }
    }

    @ViewBuilder
    private var nextPrayerInfo: some View {
        if let next = nextPrayer, let startTime = nextPrayerStartTime {
            HStack(spacing: 6) {
                Image(systemName: next.systemImage)
                    .font(.caption)
                    .foregroundStyle(amberColor.opacity(0.7))
                Text("\(next.displayName) begins at \(Self.timeFormatter.string(from: startTime))")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(amberColor.opacity(0.08), in: Capsule())
        }
    }

    private var dismissField: some View {
        VStack(spacing: 6) {
            Text("Type **inshallah** to dismiss")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("", text: $dismissText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
                .multilineTextAlignment(.center)
        }
    }

    private var actions: some View {
        Button(action: onDismiss) {
            Text("Dismiss")
                .font(.body.weight(.semibold))
                .frame(width: 160, height: 36)
        }
        .buttonStyle(.borderedProminent)
        .tint(amberColor)
        .controlSize(.large)
        .disabled(!canDismiss)
    }

    private var amberColor: Color {
        Color.orange
    }

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let remaining = Int(max(0, prayerEndTime.timeIntervalSince(Date())))
            remainingSeconds = remaining
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
}
