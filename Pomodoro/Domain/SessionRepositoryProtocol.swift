import Foundation

protocol SessionRepositoryProtocol {
    func saveSession(duration: TimeInterval, type: SessionType, isCompleted: Bool)
    func fetchAllSessions() -> [PomodoroSession]
    func fetchSessions(for type: SessionType) -> [PomodoroSession]
}
