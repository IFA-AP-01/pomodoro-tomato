import Foundation
import SwiftData

enum SessionType: String, Codable {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
}

@Model
final class PomodoroSession {
    var id: UUID
    var startTime: Date
    var duration: TimeInterval
    var typeRawValue: String
    
    var type: SessionType {
        get { SessionType(rawValue: typeRawValue) ?? .focus }
        set { typeRawValue = newValue.rawValue }
    }
    var isCompleted: Bool

    init(id: UUID = UUID(), startTime: Date = Date(), duration: TimeInterval, type: SessionType, isCompleted: Bool = false) {
        self.id = id
        self.startTime = startTime
        self.duration = duration
        self.typeRawValue = type.rawValue
        self.isCompleted = isCompleted
    }
}
