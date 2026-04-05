import SwiftUI

struct DayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let isCurrentMonth: Bool
    let hasEvents: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 13, weight: isToday ? .bold : .regular))
                .foregroundStyle(foregroundColor)
                .frame(width: 30, height: 30)
                .background(background)

            Circle()
                .fill(dotColor)
                .frame(width: 4, height: 4)
        }
        .frame(height: 38)
        .contentShape(Rectangle())
    }

    private var foregroundColor: Color {
        if isSelected { return .white }
        if !isCurrentMonth { return .secondary.opacity(0.5) }
        if isToday { return .accentColor }
        return .primary
    }

    private var dotColor: Color {
        if !hasEvents { return .clear }
        if isSelected { return .white.opacity(0.7) }
        if !isCurrentMonth { return .accentColor.opacity(0.3) }
        return .accentColor
    }

    @ViewBuilder
    private var background: some View {
        if isSelected {
            Circle()
                .fill(Color.accentColor)
        } else if isToday {
            Circle()
                .strokeBorder(Color.accentColor, lineWidth: 1.5)
        } else {
            Color.clear
        }
    }
}
