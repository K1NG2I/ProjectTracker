import SwiftUI
import SwiftData

struct WeekCalendarView: View {
    let selectedDate: Date
    let onEntrySelected: (Entry) -> Void

    @Query private var timeSegments: [TimeSegment]
    @State private var currentWeekStart: Date

    private let calendar = Calendar.current
    private let hourHeight: CGFloat = 50

    init(selectedDate: Date, onEntrySelected: @escaping (Entry) -> Void) {
        self.selectedDate = selectedDate
        self.onEntrySelected = onEntrySelected
        _currentWeekStart = State(initialValue: Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) ?? selectedDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            weekNavigation
            dayHeaders
            Divider()
            timelineArea
        }
    }

    private var weekNavigation: some View {
        HStack {
            Button(action: previousWeek) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(weekRangeString)
                .font(.subheadline.weight(.semibold))
            Spacer()
            Button(action: nextWeek) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    private var dayHeaders: some View {
        HStack(spacing: 0) {
            Color.clear
                .frame(width: 40)
            ForEach(0..<7, id: \.self) { offset in
                if let dayDate = calendar.date(byAdding: .day, value: offset, to: currentWeekStart) {
                    let isToday = calendar.isDateInToday(dayDate)
                    VStack(spacing: 1) {
                        Text(calendar.shortWeekdaySymbols[offset])
                            .font(.caption2.weight(.medium))
                            .foregroundColor(isToday ? .accentColor : .secondary)
                        Text("\(calendar.component(.day, from: dayDate))")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(isToday ? .accentColor : .primary)
                    }
                    .frame(width: 100)
                }
            }
        }
        .padding(.bottom, 4)
    }

    private var timelineArea: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(spacing: 0) {
                timeColumn
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { offset in
                        dayTimeline(weekDay: offset)
                            .frame(width: 100)
                    }
                }
            }
        }
    }

    private var timeColumn: some View {
        VStack(spacing: 0) {
            ForEach(6..<23) { hour in
                Text(String(format: "%d:00", hour))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(height: hourHeight, alignment: .topLeading)
                    .padding(.top, -6)
                    .padding(.trailing, 4)
            }
        }
        .frame(width: 40)
        .padding(.top, 2)
    }

    private func dayTimeline(weekDay: Int) -> some View {
        guard let dayDate = calendar.date(byAdding: .day, value: weekDay, to: currentWeekStart) else {
            return AnyView(Color.clear)
        }

        let daySegments = timeSegments.filter { calendar.isDate($0.date, inSameDayAs: dayDate) }

        return AnyView(
            ZStack(alignment: .topLeading) {
                ForEach(6..<23) { hour in
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: hourHeight)
                        .overlay(alignment: .top) {
                            if hour != 6 {
                                Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 0.5)
                            }
                        }
                }

                ForEach(daySegments) { segment in
                    if let entry = segment.entry {
                        let startHour = calendar.component(.hour, from: segment.startTime)
                        let startMin = calendar.component(.minute, from: segment.startTime)
                        let endHour = calendar.component(.hour, from: segment.endTime)
                        let endMin = calendar.component(.minute, from: segment.endTime)

                        let yOffset = CGFloat(startHour - 6) * hourHeight + CGFloat(startMin) * hourHeight / 60
                        let durationH = CGFloat(endHour - startHour) + CGFloat(endMin - startMin) / 60
                        let height = durationH * hourHeight

                        RoundedRectangle(cornerRadius: 4)
                            .fill(entry.type.color.opacity(0.3))
                            .overlay(
                                VStack(spacing: 1) {
                                    Text(entry.title)
                                        .font(.system(size: 8))
                                        .lineLimit(2)
                                    StageBadge(stage: entry.stage)
                                        .scaleEffect(0.7)
                                }
                                .padding(2),
                                alignment: .top
                            )
                            .frame(height: max(height, 20))
                            .offset(y: yOffset)
                            .contentShape(.rect)
                            .onTapGesture { onEntrySelected(entry) }
                    }
                }
            }
        )
    }

    private var weekRangeString: String {
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentWeekStart)),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        let endF = DateFormatter()
        endF.dateFormat = "d, yyyy"
        return "\(f.string(from: weekStart)) - \(endF.string(from: weekEnd))"
    }

    private func previousWeek() {
        currentWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) ?? currentWeekStart
    }

    private func nextWeek() {
        currentWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) ?? currentWeekStart
    }
}
