import SwiftUI

@Observable
class SettingsViewModel {
    var settingsService: SettingsService
    var timerEngine: TimerEngine
    
    init(settingsService: SettingsService, timerEngine: TimerEngine) {
        self.settingsService = settingsService
        self.timerEngine = timerEngine
    }
    
    func applySettingsChanges() {
        if timerEngine.sessionState != .idle {
            forceResetTimer()
        } else {
            timerEngine.setupNewSession(type: .focus, durationMinutes: settingsService.focusTimeMinutes)
        }
    }
    
    func forceResetTimer() {
        timerEngine.setupNewSession(type: .focus, durationMinutes: settingsService.focusTimeMinutes)
    }
}
