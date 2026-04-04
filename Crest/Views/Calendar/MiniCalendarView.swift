import SwiftUI

struct MiniCalendarView: View {
    var calendarService: CalendarService
    @Binding var selectedDate: Date?

    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(spacing: 8) {
            monthNavigation
            weekdayHeaders
            daysGrid
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var monthNavigation: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.caption.weight(.semibold))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(monthYearString)
                .font(.subheadline.weight(.semibold))

            Spacer()

            Button(action: { displayedMonth = Date() }) {
                Text("Today")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
            }
            .buttonStyle(.plain)
        }
    }

    private var weekdayHeaders: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        let days = generateDays()
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(days, id: \.self) { day in
                if let day {
                    DayCell(
                        date: day,
                        isToday: calendar.isDateInToday(day),
                        isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: day) } ?? false,
                        isCurrentMonth: calendar.isDate(day, equalTo: displayedMonth, toGranularity: .month),
                        hasEvents: calendarService.hasEvents(on: day)
                    )
                    .onTapGesture {
                        if selectedDate.map({ calendar.isDate($0, inSameDayAs: day) }) == true {
                            selectedDate = nil
                        } else {
                            selectedDate = day
                        }
                    }
                } else {
                    Color.clear
                        .frame(height: 32)
                }
            }
        }
    }

    private func generateDays() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date?] = []
        let startWeekday = calendar.component(.weekday, from: monthInterval.start)
        let prefixCount = startWeekday - calendar.firstWeekday
        let adjustedPrefix = prefixCount < 0 ? prefixCount + 7 : prefixCount

        for _ in 0..<adjustedPrefix {
            days.append(nil)
        }

        let daysInMonth = calendar.range(of: .day, in: .month, for: displayedMonth)!
        for day in daysInMonth {
            if let date = calendar.date(bySetting: .day, value: day, of: displayedMonth) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func previousMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
    }

    private func nextMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }
}
