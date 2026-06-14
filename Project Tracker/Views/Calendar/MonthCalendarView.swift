import SwiftUI
import SwiftData

struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    let onDaySelected: (Date) -> Void
    let onEntrySelected: (Entry) -> Void

    @Query private var entries: [Entry]
    @State private var currentMonth: Date

    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()
    private let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    init(selectedDate: Binding<Date>, onDaySelected: @escaping (Date) -> Void, onEntrySelected: @escaping (Entry) -> Void) {
        _selectedDate = selectedDate
        self.onDaySelected = onDaySelected
        self.onEntrySelected = onEntrySelected
        _currentMonth = State(initialValue: Calendar.current.startOfMonth(for: selectedDate.wrappedValue))
    }

    var body: some View {
        VStack(spacing: 6) {
            monthHeader
            weekdayHeader
            calendarGrid
        }
        .padding(.horizontal, 6)
    }

    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthYearFormatter.string(from: currentMonth))
                .font(.title3.weight(.semibold))
            Spacer()
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal, 4)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let days = generateDays()
        let rows = days.chunked(into: 7)

        return VStack(spacing: 4) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    ForEach(week, id: \.id) { day in
                        dayCell(day)
                    }
                }
            }
        }
    }

    private func dayCell(_ day: DayModel) -> some View {
        let hasEntries = entries.contains { entry in
            entry.timeSegments.contains { segment in
                calendar.isDate(segment.date, inSameDayAs: day.date)
            }
        }
        let isToday = calendar.isDateInToday(day.date)
        let isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)
        let isCurrentMonth = calendar.isDate(day.date, equalTo: currentMonth, toGranularity: .month)

        return VStack(spacing: 2) {
            Text(dayFormatter.string(from: day.date))
                .font(.callout)
                .foregroundColor(
                    !isCurrentMonth ? .secondary.opacity(0.4) :
                    isSelected ? .white : (isToday ? .accentColor : .primary)
                )
                .frame(width: 32, height: 32)
                .background(
                    isSelected ? Color.accentColor : (isToday ? Color.accentColor.opacity(0.15) : .clear),
                    in: .circle
                )

            if hasEntries {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 5, height: 5)
            } else {
                Color.clear.frame(width: 5, height: 5)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .contentShape(.rect)
        .onTapGesture {
            selectedDate = day.date
            onDaySelected(day.date)
        }
    }

    private func generateDays() -> [DayModel] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }

        var days: [DayModel] = []
        var date = monthFirstWeek.start
        while date < monthLastWeek.end {
            days.append(DayModel(date: date, id: date.timeIntervalSince1970))
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        return days
    }

    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

private struct DayModel {
    let date: Date
    let id: TimeInterval
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
