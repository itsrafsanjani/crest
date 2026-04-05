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
            HStack {
                Text("Prayer Times")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(.bar)

            ForEach(prayerTimeService.todayPrayers) { pt in
                prayerRow(pt)
                if pt.prayer != .isha {
                    Divider().padding(.horizontal, 16)
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
