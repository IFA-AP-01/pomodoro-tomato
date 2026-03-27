import ActivityKit
import Foundation

struct PomodoroActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentSessionType: String // "Focus", "Short Break", "Long Break"
        var timeRemaining: TimeInterval
        var totalDuration: TimeInterval
        var sessionState: String // "running", "paused", "finished"
        var targetDate: Date // For the countdown timer in the widget
        var currentCycleIndex: Int
        var cyclesBeforeLongBreak: Int
    }

    var taskName: String
}
