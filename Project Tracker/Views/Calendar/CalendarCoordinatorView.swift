import SwiftUI

enum CalendarViewMode: String, CaseIterable {
    case month = "Month"
    case day = "Day"
}

struct CalendarCoordinatorView: View {
    @State private var viewMode: CalendarViewMode = .month
    @State private var selectedDate = Date()
    @State private var selectedEntry: Entry?
    @State private var showEntryDetail = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $viewMode) {
                    ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 6)

                Group {
                    switch viewMode {
                    case .month:
                        MonthCalendarView(
                            selectedDate: $selectedDate,
                            onDaySelected: { date in
                                selectedDate = date
                                viewMode = .day
                            },
                            onEntrySelected: { entry in
                                selectedEntry = entry
                                showEntryDetail = true
                            }
                        )
                        .frame(maxHeight: .infinity, alignment: .top)
                    case .day:
                        DayTimelineView(
                            date: selectedDate,
                            onEntrySelected: { entry in
                                selectedEntry = entry
                                showEntryDetail = true
                            }
                        )
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Today") {
                        selectedDate = Date()
                    }
                    .font(.subheadline)
                }
            }
            .sheet(isPresented: $showEntryDetail) {
                if let entry = selectedEntry {
                    EntryFormView(editing: entry)
                }
            }
        }
    }

    private var navigationTitle: String {
        switch viewMode {
        case .month:
            let f = DateFormatter()
            f.dateFormat = "MMMM yyyy"
            return f.string(from: selectedDate)
        case .day:
            let f = DateFormatter()
            f.dateFormat = "EEEE, MMM d"
            return f.string(from: selectedDate)
        }
    }
}
