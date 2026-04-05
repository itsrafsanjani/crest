import SwiftUI

struct PrayerTimesView: View {
    var prayerTimeService: PrayerTimeService

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            Text("Prayer Times")
                .font(.caption.weight(.semibold))
                .tracking(0.5)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.primary.opacity(0.04))

            ForEach(prayerTimeService.todayPrayers) { pt in
                prayerRow(pt)
                if pt.prayer != .isha {
                    Divider().padding(.leading, 42)
                }
            }
        }
        .padding(.bottom, 4)
    }

    private func prayerRow(_ pt: PrayerTime) -> some View {
        let isNext = prayerTimeService.nextPrayer == pt.prayer
        let isPast = pt.isPast()

        return HStack(spacing: 8) {
            Image(systemName: pt.prayer.systemImage)
                .font(.system(size: 12))
                .foregroundStyle(isNext ? Color.accentColor : (isPast ? Color.secondary.opacity(0.4) : Color.secondary))
                .frame(width: 18)

            Text(pt.prayer.displayName)
                .font(.callout.weight(isNext ? .semibold : .regular))
                .foregroundStyle(isPast ? .tertiary : .primary)

            Spacer()

            if isNext {
                Text("in \(prayerTimeService.formattedCountdown())")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.12), in: Capsule())
            }

            Text(timeFormatter.string(from: pt.time))
                .font(.callout.monospacedDigit())
                .foregroundStyle(isPast ? .tertiary : .secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(isNext ? Color.accentColor.opacity(0.05) : .clear)
    }
}
