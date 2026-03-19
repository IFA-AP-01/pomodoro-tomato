import Foundation
import SwiftData

class LocalSessionRepository: SessionRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveSession(duration: TimeInterval, type: SessionType, isCompleted: Bool) {
        let session = PomodoroSession(duration: duration, type: type, isCompleted: isCompleted)
        modelContext.insert(session)
        try? modelContext.save()
    }
    
    func fetchAllSessions() -> [PomodoroSession] {
        let descriptor = FetchDescriptor<PomodoroSession>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func fetchSessions(for type: SessionType) -> [PomodoroSession] {
        let descriptor = FetchDescriptor<PomodoroSession>(predicate: #Predicate { $0.typeRawValue == type.rawValue }, sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
