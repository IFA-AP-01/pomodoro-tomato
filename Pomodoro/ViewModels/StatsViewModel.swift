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
}
