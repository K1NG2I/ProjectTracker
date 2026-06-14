import Foundation
import SwiftData

@Model
final class Entry {
    var id: UUID = UUID()
    var title: String = ""
    var desc: String = ""
    var typeRaw: String = EntryType.other.rawValue
    var stageRaw: String = Stage.documentation.rawValue
    var bugSeverityRaw: String?
    var bugStatusRaw: String?
    var bugSteps: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade)
    var timeSegments: [TimeSegment] = []

    var type: EntryType {
        get { EntryType(rawValue: typeRaw) ?? .other }
        set { typeRaw = newValue.rawValue }
    }

    var stage: Stage {
        get { Stage(rawValue: stageRaw) ?? .documentation }
        set { stageRaw = newValue.rawValue }
    }

    var bugSeverity: BugSeverity? {
        get { bugSeverityRaw.flatMap { BugSeverity(rawValue: $0) } }
        set { bugSeverityRaw = newValue?.rawValue }
    }

    var bugStatus: BugStatus? {
        get { bugStatusRaw.flatMap { BugStatus(rawValue: $0) } }
        set { bugStatusRaw = newValue?.rawValue }
    }

    init(title: String = "", desc: String = "", type: EntryType = .other, stage: Stage = .documentation) {
        self.title = title
        self.desc = desc
        self.typeRaw = type.rawValue
        self.stageRaw = stage.rawValue
    }

    func advanceStage() {
        if let next = stage.next() {
            stage = next
            updatedAt = Date()
        }
    }
}
