import SwiftUI

enum EntryType: String, CaseIterable, Codable {
    case api = "API"
    case bug = "Bug"
    case meeting = "Meeting"
    case other = "Other"

    var color: Color {
        switch self {
        case .api: return .blue
        case .bug: return .red
        case .meeting: return .green
        case .other: return .gray
        }
    }

    var icon: String {
        switch self {
        case .api: return "gearshape.2"
        case .bug: return "ant"
        case .meeting: return "person.2"
        case .other: return "ellipsis.circle"
        }
    }
}

enum Stage: String, CaseIterable, Codable {
    case documentation = "Documentation"
    case development = "Development"
    case testing = "Testing"
    case rest = "Rest"
    case done = "Done"

    var color: Color {
        switch self {
        case .documentation: return .teal
        case .development: return .orange
        case .testing: return .purple
        case .rest: return .yellow
        case .done: return .green
        }
    }

    func next() -> Stage? {
        switch self {
        case .documentation: return .development
        case .development: return .testing
        case .testing: return .rest
        case .rest: return .done
        case .done: return nil
        }
    }
}

enum BugSeverity: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

enum BugStatus: String, CaseIterable, Codable {
    case open = "Open"
    case inProgress = "In Progress"
    case resolved = "Resolved"
    case closed = "Closed"
}
