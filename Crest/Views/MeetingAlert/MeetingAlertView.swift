import SwiftUI

struct MeetingAlertView: View {
    let eventTitle: String
    let timeRange: String
    let calendarName: String
    let calendarColor: Color
    let serviceName: String
    let attendees: [String]
    let onJoin: () -> Void
    let onDismiss: () -> Void

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                alertCard
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
            }
        }
    }

    private var alertCard: some View {
        VStack(spacing: 24) {
            pulseRing
            eventInfo
            if !attendees.isEmpty {
                attendeeSection
            }
            actions
        }
        .padding(40)
        .frame(width: 480)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 40, y: 10)
    }

    private var pulseRing: some View {
        ZStack {
            Circle()
                .stroke(calendarColor.opacity(0.2), lineWidth: 3)
                .frame(width: 72, height: 72)
                .scaleEffect(pulseScale)

            Circle()
                .fill(calendarColor.opacity(0.15))
                .frame(width: 64, height: 64)

            Image(systemName: "video.fill")
                .font(.system(size: 26))
                .foregroundStyle(calendarColor)
        }
    }

    private var eventInfo: some View {
        VStack(spacing: 10) {
            Text("Meeting Starting Now")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)

            Text(eventTitle)
                .font(.title.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(3)

            HStack(spacing: 12) {
                Label(timeRange, systemImage: "clock")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Text("·")
                    .foregroundStyle(.tertiary)

                HStack(spacing: 4) {
                    Circle()
                        .fill(calendarColor)
                        .frame(width: 8, height: 8)
                    Text(calendarName)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            serviceBadge
        }
    }

    private var serviceBadge: some View {
        Text(serviceName)
            .font(.caption.weight(.medium))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(calendarColor.opacity(0.7), in: Capsule())
    }

    private var attendeeSection: some View {
        VStack(spacing: 6) {
            let count = attendees.count
            let displayCount = min(count, 5)
            let displayed = attendees.prefix(displayCount)

            HStack(spacing: 4) {
                Image(systemName: "person.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(count) attendee\(count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(displayed.joined(separator: ", ") + (count > displayCount ? " + \(count - displayCount) more" : ""))
                .font(.caption)
                .foregroundStyle(.tertiary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
    }

    private var actions: some View {
        HStack(spacing: 16) {
            Button(action: onDismiss) {
                Text("Dismiss")
                    .font(.body.weight(.medium))
                    .frame(width: 120, height: 36)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .keyboardShortcut(.escape, modifiers: [])

            Button(action: onJoin) {
                Label("Join Meeting", systemImage: "video.fill")
                    .font(.body.weight(.semibold))
                    .frame(width: 160, height: 36)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.return, modifiers: [])
        }
    }
}
