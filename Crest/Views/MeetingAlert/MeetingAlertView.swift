import SwiftUI

struct MeetingAlertView: View {
    let eventTitle: String
    let eventStartDate: Date
    let timeRange: String
    let calendarName: String
    let calendarColor: Color
    let serviceName: String
    let attendees: [String]
    let onJoin: () -> Void
    let onDismiss: () -> Void
    let onSnooze: (Int) -> Void

    @State private var currentTime = Date()
    @State private var timer: Timer?

    private var minutesUntilStart: Int {
        max(0, Int(ceil(eventStartDate.timeIntervalSince(currentTime) / 60)))
    }

    private var timeUntilText: String {
        let mins = minutesUntilStart
        if mins <= 0 { return "Starting now" }
        if mins == 1 { return "In 1 minute" }
        return "In \(mins) minutes"
    }

    var body: some View {
        ZStack {
            gradientBackground
            mainContent
            clockBadge
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                currentTime = Date()
            }
            if let timer { RunLoop.main.add(timer, forMode: .common) }
        }
        .onDisappear { timer?.invalidate() }
    }

    private var gradientBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.35),
                    Color(red: 0.3, green: 0.15, blue: 0.5),
                    Color(red: 0.5, green: 0.2, blue: 0.55),
                    Color(red: 0.3, green: 0.1, blue: 0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color(red: 0.6, green: 0.25, blue: 0.65).opacity(0.4),
                    .clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var clockBadge: some View {
        VStack {
            HStack {
                Spacer()
                Text(clockString)
                    .font(.system(size: 14, weight: .medium, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 40)
                    .padding(.trailing, 24)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(eventTitle)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 40)
                .padding(.bottom, 12)

            Text(timeUntilText)
                .font(.title3.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.bottom, 6)

            Text(timeRange)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.bottom, 28)

            actionButtons
                .padding(.bottom, 16)

            snoozeOptions

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: onDismiss) {
                Text("Dismiss")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.12), in: Capsule())
                    .overlay(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.escape, modifiers: [])

            Button(action: onJoin) {
                HStack(spacing: 6) {
                    Text("Join Video Call")
                        .font(.body.weight(.semibold))
                    Image(systemName: "video.fill")
                        .font(.caption)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(Color.accentColor, in: Capsule())
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: [])
        }
    }

    private var snoozeOptions: some View {
        VStack(spacing: 10) {
            Text("Snooze")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))

            HStack(spacing: 8) {
                snoozeButton("1 minute", minutes: 1)
                snoozeButton("5 minutes", minutes: 5)
                snoozeButton("Until Event", minutes: max(1, minutesUntilStart))
            }
        }
    }

    private func snoozeButton(_ title: String, minutes: Int) -> some View {
        Button {
            onSnooze(minutes)
        } label: {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(.white.opacity(0.08), in: Capsule())
                .overlay(Capsule().strokeBorder(.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var clockString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: currentTime)
    }
}
