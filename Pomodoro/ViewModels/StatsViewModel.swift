import SwiftUI
import SwiftData

@Observable
class StatsViewModel {
    private var repository: SessionRepositoryProtocol?
    var settings: SettingsService
    
    var sessions: [PomodoroSession] = []
    
    init(settings: SettingsService) {
        self.settings = settings
    }
    
    func setup(modelContext: ModelContext) {
        self.repository = LocalSessionRepository(modelContext: modelContext)
        refreshData()
    }
    
    func refreshData() {
        sessions = repository?.fetchAllSessions() ?? []
    }
    
    var todayFocusSeconds: TimeInterval {
        sessions
            .filter { $0.type == .focus && Calendar.current.isDateInToday($0.startTime) }
            .reduce(0) { $0 + $1.duration }
    }
    
    var totalFocusSeconds: TimeInterval {
        sessions
            .filter { $0.type == .focus }
            .reduce(0) { $0 + $1.duration }
    }
    
    private func getFocusSeconds(for date: Date) -> TimeInterval {
        sessions
            .filter { $0.type == .focus && Calendar.current.isDate($0.startTime, inSameDayAs: date) }
            .reduce(0) { $0 + $1.duration }
    }
    
    var last7DaysData: [(label: String, value: Double)] {
        var data: [(label: String, value: Double)] = []
        let cal = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Mon, Tue...
        
        for i in (0..<7).reversed() {
            if let date = cal.date(byAdding: .day, value: -i, to: today) {
                let seconds = getFocusSeconds(for: date)
                data.append((label: formatter.string(from: date), value: seconds / 60.0)) // in minutes
            }
        }
        return data
    }
    
    var thisMonthData: [(label: String, value: Double)] {
        var data: [(label: String, value: Double)] = []
        let cal = Calendar.current
        let today = Date()
        guard let range = cal.range(of: .day, in: .month, for: today),
              let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: today)) else { return [] }
        
        for i in range {
            if let date = cal.date(byAdding: .day, value: i - 1, to: startOfMonth), date <= today {
                let seconds = getFocusSeconds(for: date)
                data.append((label: "\(i)", value: seconds / 60.0)) // in minutes
            }
        }
        return data
    }
    
    var thisYearData: [(label: String, value: Double)] {
        var data: [(label: String, value: Double)] = []
        let cal = Calendar.current
        let today = Date()
        let currentYear = cal.component(.year, from: today)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        for i in 1...12 {
            if let date = cal.date(from: DateComponents(year: currentYear, month: i, day: 1)) {
                let seconds = sessions
                    .filter { $0.type == .focus && cal.component(.month, from: $0.startTime) == i && cal.component(.year, from: $0.startTime) == currentYear }
                    .reduce(0) { $0 + $1.duration }
                data.append((label: formatter.string(from: date), value: seconds / 3600.0)) // in hours
            }
        }
        return data
    }
}
