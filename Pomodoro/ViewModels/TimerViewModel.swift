import SwiftUI

@Observable
class TimerViewModel {
    var timerEngine: TimerEngine
    var settings: SettingsService
    
    init(timerEngine: TimerEngine, settings: SettingsService) {
        self.timerEngine = timerEngine
        self.settings = settings
    }
    
    func reset() {
        timerEngine.reset()
    }
    
    func togglePlayPause() {
        if timerEngine.sessionState == .running {
            timerEngine.pause()
        } else {
            if timerEngine.sessionState == .idle && timerEngine.timeRemaining == 0 {
                timerEngine.setupNewSession(type: .focus, durationMinutes: settings.focusTimeMinutes)
            }
            timerEngine.start()
        }
    }
    
    func skip() {
        timerEngine.skip(settings: settings)
    }
    
    func performUndoReset() {
        timerEngine.performUndoReset()
    }
    
    func checkAndSetupInitialSession() {
        if timerEngine.sessionState == .idle && timerEngine.timeRemaining == 0 {
            timerEngine.setupNewSession(type: .focus, durationMinutes: settings.focusTimeMinutes)
        }
    }
}
