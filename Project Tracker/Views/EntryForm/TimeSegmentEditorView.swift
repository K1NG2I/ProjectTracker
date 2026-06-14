import SwiftUI

struct TimeSegmentEditorView: View {
    @Binding var segments: [TimeSegmentDraft]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(segments.indices, id: \.self) { index in
                    VStack(spacing: 8) {
                        HStack {
                            DatePicker("Date", selection: $segments[index].date, displayedComponents: .date)
                            Spacer()
                            Button {
                                segments.remove(at: index)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }

                        HStack {
                            DatePicker("Start", selection: $segments[index].startTime, displayedComponents: .hourAndMinute)
                            DatePicker("End", selection: $segments[index].endTime, displayedComponents: .hourAndMinute)
                        }
                        .labelsHidden()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    segments.remove(atOffsets: indexSet)
                }

                Button {
                    let defaultDate = segments.last?.date ?? Date()
                    let lastEnd = segments.last?.endTime ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: defaultDate) ?? Date()
                    let newStart = Calendar.current.date(byAdding: .hour, value: 1, to: lastEnd) ?? lastEnd
                    let newEnd = Calendar.current.date(byAdding: .hour, value: 1, to: newStart) ?? newStart
                    segments.append(TimeSegmentDraft(date: defaultDate, startTime: newStart, endTime: newEnd))
                } label: {
                    Label("Add Time Block", systemImage: "plus")
                }
            }
            .navigationTitle("Time Blocks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct TimeSegmentDraft: Identifiable {
    let id = UUID()
    var date: Date
    var startTime: Date
    var endTime: Date
}
