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
                .font(.system(size: 12, weight: isToday ? .bold : .regular))
                .foregroundStyle(foregroundColor)
                .frame(width: 28, height: 28)
                .background(background)

            Circle()
                .fill(hasEvents ? Color.accentColor : Color.clear)
                .frame(width: 4, height: 4)
        }
        .frame(height: 36)
        .contentShape(Rectangle())
    }

    private var foregroundColor: Color {
        if isSelected { return .white }
        if !isCurrentMonth { return .secondary.opacity(0.4) }
        if isToday { return .accentColor }
        return .primary
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
