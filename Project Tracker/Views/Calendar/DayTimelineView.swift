import SwiftUI
import SwiftData

private struct LayoutSegment: Identifiable {
    let id = UUID()
    let segment: TimeSegment
    let entry: Entry
    let yOffset: CGFloat
    let height: CGFloat
    var column: Int = 0
    var totalColumns: Int = 1
}

struct DayTimelineView: View {
    let date: Date
    let onEntrySelected: (Entry) -> Void

    @Query private var allSegments: [TimeSegment]
    @Environment(\.modelContext) private var modelContext

    private let calendar = Calendar.current
    private let hourHeight: CGFloat = 60
    private let startHour = 6
    private let endHour = 23

    init(date: Date, onEntrySelected: @escaping (Entry) -> Void) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        self.date = startOfDay
        self.onEntrySelected = onEntrySelected
        let predicate = #Predicate<TimeSegment> { segment in
            segment.date == startOfDay
        }
        _allSegments = Query(filter: predicate, sort: \.startTime)
    }

    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                timeRuler
                entryBlocks
            }
            .padding(.leading, 56)
            .padding(.trailing, 8)
            .frame(height: CGFloat(endHour - startHour) * hourHeight)
        }
        .scrollIndicators(.hidden)
    }

    private var timeRuler: some View {
        VStack(spacing: 0) {
            ForEach(startHour..<endHour, id: \.self) { hour in
                VStack(spacing: 0) {
                    Text(String(format: "%d:00", hour))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .offset(y: -6)
                        .padding(.leading, -52)

                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 0.5)
                }
                .frame(height: hourHeight)
            }
        }
    }

    private var entryBlocks: some View {
        let layout = computeLayout()
        return GeometryReader { geo in
            let totalWidth = geo.size.width
            ForEach(layout) { item in
                let w = totalWidth / CGFloat(item.totalColumns)
                let x = w * CGFloat(item.column)
                timelineBlock(entry: item.entry, segment: item.segment)
                    .frame(width: w - 4, height: item.height)
                    .offset(x: x + 2, y: item.yOffset)
            }
        }
    }

    private func timelineBlock(entry: Entry, segment: TimeSegment) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(entry.type.color.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(entry.type.color.opacity(0.3))
                    .frame(height: 3),
                alignment: .top
            )
            .overlay(blockContent(entry: entry, segment: segment), alignment: .topLeading)
            .contentShape(.rect)
            .onTapGesture { onEntrySelected(entry) }
            .contextMenu {
                Button {
                    entry.advanceStage()
                } label: {
                    if let next = entry.stage.next() {
                        Label("Move to \(next.rawValue)", systemImage: "arrow.right")
                    } else {
                        Label("Already Done", systemImage: "checkmark")
                    }
                }
                Button {
                    onEntrySelected(entry)
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
    }

    private func blockContent(entry: Entry, segment: TimeSegment) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                TypeIcon(type: entry.type, size: 18)
                Text(entry.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Spacer()
                StageBadge(stage: entry.stage)
            }
            Text(segment.formattedTimeRange)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
    }

    private func computeLayout() -> [LayoutSegment] {
        let items = allSegments.filter { $0.entry != nil }
        var layout = items.map { segment -> LayoutSegment in
            let entry = segment.entry!
            let startComp = calendar.dateComponents([.hour, .minute], from: segment.startTime)
            let endComp = calendar.dateComponents([.hour, .minute], from: segment.endTime)
            let startH = startComp.hour ?? startHour
            let startM = startComp.minute ?? 0
            let endH = endComp.hour ?? startHour
            let endM = endComp.minute ?? 0
            let yOff = CGFloat(startH - startHour) * hourHeight + CGFloat(startM) * hourHeight / 60
            let dur = CGFloat(endH - startH) + CGFloat(endM - startM) / 60
            let h = max(dur * hourHeight, 24)
            return LayoutSegment(segment: segment, entry: entry, yOffset: yOff, height: h)
        }

        layout.sort { $0.segment.startTime < $1.segment.startTime }

        for i in layout.indices {
            var occupied = Set<Int>()
            for j in 0..<i {
                if overlaps(layout[i], layout[j]) {
                    occupied.insert(layout[j].column)
                }
            }
            var col = 0
            while occupied.contains(col) { col += 1 }
            layout[i].column = col
        }

        for i in layout.indices {
            var maxCol = layout[i].column
            for j in layout.indices where i != j {
                if overlaps(layout[i], layout[j]) {
                    maxCol = max(maxCol, layout[j].column)
                }
            }
            layout[i].totalColumns = maxCol + 1
        }

        return layout
    }

    private func overlaps(_ a: LayoutSegment, _ b: LayoutSegment) -> Bool {
        a.segment.startTime < b.segment.endTime && b.segment.startTime < a.segment.endTime
    }
}
