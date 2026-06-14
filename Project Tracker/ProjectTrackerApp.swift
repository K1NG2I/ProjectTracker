import SwiftUI
import SwiftData

@main
struct ProjectTrackerApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Entry.self, TimeSegment.self)
            seedIfNeeded()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(container)
    }

    private func seedIfNeeded() {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Entry>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        let now = Date()
        let cal = Calendar.current
        let today = cal.startOfDay(for: now)

        func makeTime(hour: Int, minute: Int = 0) -> Date {
            cal.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? now
        }

        let seedEntries: [(title: String, desc: String, type: EntryType, stage: Stage, severity: BugSeverity?, status: BugStatus?, steps: String?, segments: [(dayOffset: Int, startHour: Int, startMin: Int, endHour: Int, endMin: Int)])] = [
            ("SAP Phase 1 - API", "REST API development for SAP Phase 1 integration", .api, .done, nil, nil, nil,
             [(0, 9, 0, 11, 30), (0, 14, 0, 16, 0)]),

            ("SAP Phase 2", "Getting more info, setting up a meet with stakeholders", .api, .documentation, nil, nil, nil,
             [(0, 11, 30, 13, 0)]),

            ("Sprint planning", "Biweekly sprint planning and backlog grooming", .meeting, .done, nil, nil, nil,
             [(0, 10, 0, 11, 0)]),

            ("Database Access Replacement", "Documentation done, development in progress", .api, .development, nil, nil, nil,
             [(0, 14, 0, 16, 30), (1, 15, 0, 17, 0), (2, 15, 30, 17, 0)]),

            ("AI Bot", "AI bot project work - demo preparation and development", .other, .rest, nil, nil, nil,
             [(1, 11, 0, 12, 0), (2, 9, 0, 10, 0)]),

            ("RPayroll - Payroll API", "Yet to start documentation for payroll API", .api, .documentation, nil, nil, nil,
             [(1, 9, 0, 11, 0)]),

            ("Ticket Management", "Yet to start documentation for ticket management system", .other, .documentation, nil, nil, nil,
             [(1, 11, 0, 12, 30)]),

            ("GeeTee - Booking document additions", "Need to add booking document support to GeeTee", .bug, .documentation, .medium, .open, nil,
             [(1, 14, 0, 15, 0)]),

            ("SGPTL - MRLogic LR changes", "Logic changes required for MRLogic in SGPTL", .bug, .documentation, .high, .open, nil,
             [(2, 14, 0, 15, 30)]),

            ("Kunhue+Nagal Meeting", "Meeting to discuss project requirements and planning", .meeting, .documentation, nil, nil, nil,
             [(2, 10, 0, 11, 0)]),
        ]

        for entryData in seedEntries {
            let entry = Entry(title: entryData.title, desc: entryData.desc, type: entryData.type, stage: entryData.stage)
            entry.bugSeverity = entryData.severity
            entry.bugStatus = entryData.status
            entry.bugSteps = entryData.steps
            context.insert(entry)

            for seg in entryData.segments {
                let day = cal.date(byAdding: .day, value: seg.dayOffset, to: today) ?? today
                let start = cal.date(bySettingHour: seg.startHour, minute: seg.startMin, second: 0, of: day) ?? day
                let end = cal.date(bySettingHour: seg.endHour, minute: seg.endMin, second: 0, of: day) ?? day
                let ts = TimeSegment(date: day, startTime: start, endTime: end, entry: entry)
                context.insert(ts)
            }
        }

        try? context.save()
    }
}
