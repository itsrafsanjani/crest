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
        let isHighlighted = prayerTimeService.highlightedPrayer == pt.prayer
        let isPast = pt.isPast()
        let jamaatIsPast = pt.jamaatTime.map { $0 < Date() } ?? false

        return VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Image(systemName: pt.prayer.systemImage)
                    .font(.system(size: 12))
                    .foregroundStyle(isHighlighted ? Color.accentColor : (isPast ? Color.secondary.opacity(0.4) : Color.secondary))
                    .frame(width: 18)

                Text(pt.prayer.displayName)
                    .font(.callout.weight(isHighlighted ? .semibold : .regular))
                    .foregroundStyle(isPast ? .tertiary : .primary)

                Spacer()

                if isHighlighted {
                    Text(prayerTimeService.formattedHighlightCountdown())
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

            if let jamaat = pt.jamaatTime {
                jamaatRow(time: jamaat, isPast: jamaatIsPast)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, pt.jamaatTime == nil ? 6 : 4)
        .background(isHighlighted ? Color.accentColor.opacity(0.05) : .clear)
    }

    private func jamaatRow(time: Date, isPast: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 9))
                .foregroundStyle(isPast ? Color.secondary.opacity(0.3) : Color.secondary.opacity(0.7))
                .frame(width: 18)

            Text("Jamaat")
                .font(.caption)
                .foregroundStyle(isPast ? .quaternary : .secondary)

            Spacer()

            Text(timeFormatter.string(from: time))
                .font(.caption.monospacedDigit())
                .foregroundStyle(isPast ? .quaternary : .secondary)
        }
    }
}
