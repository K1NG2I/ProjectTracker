import SwiftUI
import SwiftData

struct EntryListView: View {
    @Query(sort: \Entry.updatedAt, order: .reverse) private var entries: [Entry]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedType: EntryType?
    @State private var selectedStage: Stage?
    @State private var searchText = ""
    @State private var selectedEntry: Entry?
    @State private var showEntryDetail = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                entryList
            }
            .navigationTitle("Entries")
            .sheet(isPresented: $showEntryDetail) {
                if let entry = selectedEntry {
                    EntryFormView(editing: entry)
                }
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip("All", isSelected: selectedType == nil && selectedStage == nil) {
                    selectedType = nil
                    selectedStage = nil
                }

                ForEach(EntryType.allCases, id: \.rawValue) { type in
                    filterChip(type.rawValue, isSelected: selectedType == type) {
                        selectedType = selectedType == type ? nil : type
                    }
                    .foregroundColor(type.color)
                }

                Divider().frame(height: 20)

                ForEach(Stage.allCases, id: \.rawValue) { stage in
                    filterChip(stage.rawValue, isSelected: selectedStage == stage) {
                        selectedStage = selectedStage == stage ? nil : stage
                    }
                    .foregroundColor(stage.color)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func filterChip(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(.capsule)
        }
    }

    @ViewBuilder
    private var entryList: some View {
        if filteredEntries.isEmpty {
            ContentUnavailableView(
                "No Entries",
                systemImage: "tray",
                description: Text(entries.isEmpty ? "Tap + to add your first entry" : "No entries match the filters")
            )
        } else {
            List {
                ForEach(groupedEntries.keys.sorted(by: >), id: \.self) { date in
                    Section {
                        ForEach(groupedEntries[date] ?? []) { entry in
                            entryRow(entry)
                        }
                    } header: {
                        Text(dateHeader(date))
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private func entryRow(_ entry: Entry) -> some View {
        HStack(spacing: 10) {
            TypeIcon(type: entry.type)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                if !entry.desc.isEmpty {
                    Text(entry.desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                if let firstSegment = entry.timeSegments.first {
                    Text(firstSegment.formattedTimeRange)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            StageBadge(stage: entry.stage)
        }
        .padding(.vertical, 2)
        .contentShape(.rect)
        .onTapGesture {
            selectedEntry = entry
            showEntryDetail = true
        }
        .swipeActions(edge: .trailing) {
            if entry.stage != .done {
                Button("Advance") {
                    entry.advanceStage()
                }
                .tint(entry.stage.color)
            }
        }
        .swipeActions(edge: .leading) {
            Button("Delete", role: .destructive) {
                modelContext.delete(entry)
            }
        }
    }

    private var filteredEntries: [Entry] {
        entries.filter { entry in
            let typeMatch = selectedType == nil || entry.type == selectedType
            let stageMatch = selectedStage == nil || entry.stage == selectedStage
            let searchMatch = searchText.isEmpty ||
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.desc.localizedCaseInsensitiveContains(searchText)
            return typeMatch && stageMatch && searchMatch
        }
    }

    private var groupedEntries: [Date: [Entry]] {
        Dictionary(grouping: filteredEntries) { entry in
            let date = entry.timeSegments.first?.date ?? entry.createdAt
            return Calendar.current.startOfDay(for: date)
        }
    }

    private func dateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: date)
    }
}
