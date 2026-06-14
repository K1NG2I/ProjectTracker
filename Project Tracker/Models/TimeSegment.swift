import Foundation
import SwiftData

@Model
final class TimeSegment {
    var id: UUID = UUID()
    var date: Date = Date()
    var startTime: Date = Date()
    var endTime: Date = Date()

    var entry: Entry?

    init(date: Date = Date(), startTime: Date = Date(), endTime: Date = Date(), entry: Entry? = nil) {
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.entry = entry
    }

    var duration: TimeInterval {
        max(endTime.timeIntervalSince(startTime), 0)
    }

    var durationMinutes: Int {
        Int(duration / 60)
    }

    var formattedTimeRange: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return "\(f.string(from: startTime)) - \(f.string(from: endTime))"
    }
}
