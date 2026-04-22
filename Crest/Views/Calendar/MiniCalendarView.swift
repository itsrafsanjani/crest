import SwiftUI

struct MiniCalendarView: View {
    var calendarService: CalendarService
    @Binding var selectedDate: Date?
    var hijriDateString: String?

    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(spacing: 6) {
            monthNavigation
            if let hijri = hijriDateString, !hijri.isEmpty {
                Text(hijri)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            weekdayHeaders
            daysGrid
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var monthNavigation: some View {
        HStack {
            Text(monthYearString)
                .font(.title3.weight(.semibold))
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = Date()
                        selectedDate = nil
                    }
                }

            Spacer()

            HStack(spacing: 16) {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var weekdayHeaders: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
        }
    }

    private var daysGrid: some View {
        let days = generateDays()
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                DayCell(
                    date: day.date,
                    isToday: calendar.isDateInToday(day.date),
                    isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: day.date) } ?? false,
                    isCurrentMonth: day.isCurrentMonth,
                    hasEvents: calendarService.hasEvents(on: day.date)
                )
                .onTapGesture {
                    if selectedDate.map({ calendar.isDate($0, inSameDayAs: day.date) }) == true {
                        selectedDate = nil
                    } else {
                        selectedDate = day.date
                    }
                }
            }
        }
    }

    private struct CalendarDay {
        let date: Date
        let isCurrentMonth: Bool
    }

    private func generateDays() -> [CalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }

        var days: [CalendarDay] = []

        let startWeekday = calendar.component(.weekday, from: monthInterval.start)
        let prefixCount = (startWeekday - calendar.firstWeekday + 7) % 7

        for i in (0..<prefixCount).reversed() {
            if let date = calendar.date(byAdding: .day, value: -(i + 1), to: monthInterval.start) {
                days.append(CalendarDay(date: date, isCurrentMonth: false))
            }
        }

        let daysInMonth = calendar.range(of: .day, in: .month, for: displayedMonth)!
        for day in daysInMonth {
            if let date = calendar.date(bySetting: .day, value: day, of: displayedMonth) {
                days.append(CalendarDay(date: date, isCurrentMonth: true))
            }
        }

        while days.count < 42 {
            let nextDayOffset = days.count - prefixCount - daysInMonth.count + 1
            if let date = calendar.date(byAdding: .day, value: nextDayOffset - 1, to: monthInterval.end) {
                days.append(CalendarDay(date: date, isCurrentMonth: false))
            }
        }

        return days
    }

    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        }
    }

    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }
}
