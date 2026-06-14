import SwiftUI
import SwiftData

struct EntryFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var desc: String
    @State private var type: EntryType
    @State private var stage: Stage
    @State private var bugSeverity: BugSeverity
    @State private var bugStatus: BugStatus
    @State private var bugSteps: String
    @State private var timeSegments: [TimeSegmentDraft]
    @State private var showTimeEditor = false

    private var editing: Entry?
    private var isEditing: Bool { editing != nil }

    init(editing: Entry? = nil) {
        self.editing = editing
        _title = State(initialValue: editing?.title ?? "")
        _desc = State(initialValue: editing?.desc ?? "")
        _type = State(initialValue: editing?.type ?? .other)
        _stage = State(initialValue: editing?.stage ?? .documentation)
        _bugSeverity = State(initialValue: editing?.bugSeverity ?? .medium)
        _bugStatus = State(initialValue: editing?.bugStatus ?? .open)
        _bugSteps = State(initialValue: editing?.bugSteps ?? "")

        if let entry = editing {
            _timeSegments = State(initialValue: entry.timeSegments.map {
                TimeSegmentDraft(date: $0.date, startTime: $0.startTime, endTime: $0.endTime)
            })
        } else {
            let defaultDate = Date()
            let start = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: defaultDate) ?? defaultDate
            let end = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: defaultDate) ?? defaultDate
            _timeSegments = State(initialValue: [TimeSegmentDraft(date: defaultDate, startTime: start, endTime: end)])
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                stageSection
                if type == .bug { bugSection }
                timeSection
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showTimeEditor) {
                TimeSegmentEditorView(segments: $timeSegments)
            }
        }
    }

    private var basicInfoSection: some View {
        Section("Basic Info") {
            TextField("Title", text: $title)

            Picker("Type", selection: $type) {
                ForEach(EntryType.allCases, id: \.rawValue) { type in
                    Label(type.rawValue, systemImage: type.icon).tag(type)
                }
            }

            ZStack(alignment: .topLeading) {
                if desc.isEmpty {
                    Text("Description...")
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                TextEditor(text: $desc)
                    .frame(minHeight: 80)
            }
        }
    }

    private var stageSection: some View {
        Section("Stage") {
            Picker("Stage", selection: $stage) {
                ForEach(Stage.allCases, id: \.rawValue) { stage in
                    HStack {
                        Circle()
                            .fill(stage.color)
                            .frame(width: 10, height: 10)
                        Text(stage.rawValue)
                    }.tag(stage)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var bugSection: some View {
        Section("Bug Details") {
            Picker("Severity", selection: $bugSeverity) {
                ForEach(BugSeverity.allCases, id: \.rawValue) { s in
                    Text(s.rawValue).tag(s)
                }
            }

            Picker("Status", selection: $bugStatus) {
                ForEach(BugStatus.allCases, id: \.rawValue) { s in
                    Text(s.rawValue).tag(s)
                }
            }

            ZStack(alignment: .topLeading) {
                if bugSteps.isEmpty {
                    Text("Steps to reproduce...")
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                TextEditor(text: $bugSteps)
                    .frame(minHeight: 80)
            }
        }
    }

    private var timeSection: some View {
        Section("Time Blocks") {
            ForEach(timeSegments.prefix(3)) { segment in
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formattedDate(segment.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formattedTime(segment.startTime) + " - " + formattedTime(segment.endTime))
                            .font(.subheadline)
                    }
                }
            }

            Button {
                showTimeEditor = true
            } label: {
                Text(timeSegments.count > 3 ? "Manage all \(timeSegments.count) blocks..." : timeSegments.isEmpty ? "Add time block" : "Manage time blocks")
            }
        }
    }

    private func save() {
        let entry: Entry
        if let existing = editing {
            entry = existing
            entry.timeSegments.forEach { modelContext.delete($0) }
        } else {
            entry = Entry(title: title, desc: desc, type: type, stage: stage)
            modelContext.insert(entry)
        }

        entry.title = title
        entry.desc = desc
        entry.type = type
        entry.stage = stage
        entry.updatedAt = Date()

        if type == .bug {
            entry.bugSeverity = bugSeverity
            entry.bugStatus = bugStatus
            entry.bugSteps = bugSteps
        } else {
            entry.bugSeverity = nil
            entry.bugStatus = nil
            entry.bugSteps = nil
        }

        for draft in timeSegments {
            let segment = TimeSegment(
                date: Calendar.current.startOfDay(for: draft.date),
                startTime: draft.startTime,
                endTime: draft.endTime,
                entry: entry
            )
            modelContext.insert(segment)
        }

        dismiss()
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "E, MMM d"
        return f.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}
