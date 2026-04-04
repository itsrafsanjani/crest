import SwiftUI

struct PrayerOverlayView: View {
    let prayer: Prayer
    let prayerTime: Date
    let onDismiss: () -> Void
    let onSnooze: () -> Void

    @State private var remainingSeconds: Int
    @State private var dismissText = ""
    @State private var timer: Timer?

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

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
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
            dismissField
            actions
        }
        .padding(40)
        .frame(width: 420)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 40, y: 10)
    }

    private var countdownRing: some View {
        ZStack {
            Circle()
                .stroke(Color.indigo.opacity(0.15), lineWidth: 6)
                .frame(width: 120, height: 120)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.indigo,
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

            Text(remainingSeconds > 0 ? "Prayer starting soon" : "Prayer time has begun")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)
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
        HStack(spacing: 16) {
            Button(action: onSnooze) {
                Text("Snooze 5 min")
                    .font(.body.weight(.medium))
                    .frame(width: 130, height: 36)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button(action: onDismiss) {
                Text("Dismiss")
                    .font(.body.weight(.semibold))
                    .frame(width: 130, height: 36)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .controlSize(.large)
            .disabled(!canDismiss)
        }
    }

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let remaining = Int(max(0, prayerTime.timeIntervalSince(Date())))
            remainingSeconds = remaining
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
}
