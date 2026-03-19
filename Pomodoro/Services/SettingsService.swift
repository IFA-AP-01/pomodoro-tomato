import SwiftUI

@Observable
class SettingsService {
    var focusTimeMinutes: Int {
        didSet { UserDefaults.standard.set(focusTimeMinutes, forKey: "focusTimeMinutes") }
    }
    
    var shortBreakMinutes: Int {
        didSet { UserDefaults.standard.set(shortBreakMinutes, forKey: "shortBreakMinutes") }
    }
    
    var longBreakMinutes: Int {
        didSet { UserDefaults.standard.set(longBreakMinutes, forKey: "longBreakMinutes") }
    }
    
    var cyclesBeforeLongBreak: Int {
        didSet { UserDefaults.standard.set(cyclesBeforeLongBreak, forKey: "cyclesBeforeLongBreak") }
    }
    
    var autoStartNext: Bool {
        didSet { UserDefaults.standard.set(autoStartNext, forKey: "autoStartNext") }
    }
    
    var dailyFocusGoalMinutes: Int {
        didSet { UserDefaults.standard.set(dailyFocusGoalMinutes, forKey: "dailyFocusGoalMinutes") }
    }
    
    var enableInAppAOD: Bool {
        didSet { UserDefaults.standard.set(enableInAppAOD, forKey: "enableInAppAOD") }
    }
    
    var selectedThemeID: String {
        didSet { UserDefaults.standard.set(selectedThemeID, forKey: "selectedThemeID") }
    }
    
    var currentTaskName: String {
        didSet { UserDefaults.standard.set(currentTaskName, forKey: "currentTaskName") }
    }
    
    var currentTaskTopic: String {
        didSet { UserDefaults.standard.set(currentTaskTopic, forKey: "currentTaskTopic") }
    }
    
    var currentTheme: PomodoroTheme {
        PomodoroTheme.from(id: selectedThemeID)
    }

    init() {
        // Load values from UserDefaults with defaults if not set
        self.focusTimeMinutes = UserDefaults.standard.integer(forKey: "focusTimeMinutes") == 0 ? 25 : UserDefaults.standard.integer(forKey: "focusTimeMinutes")
        self.shortBreakMinutes = UserDefaults.standard.integer(forKey: "shortBreakMinutes") == 0 ? 5 : UserDefaults.standard.integer(forKey: "shortBreakMinutes")
        self.longBreakMinutes = UserDefaults.standard.integer(forKey: "longBreakMinutes") == 0 ? 15 : UserDefaults.standard.integer(forKey: "longBreakMinutes")
        self.cyclesBeforeLongBreak = UserDefaults.standard.integer(forKey: "cyclesBeforeLongBreak") == 0 ? 4 : UserDefaults.standard.integer(forKey: "cyclesBeforeLongBreak")
        self.autoStartNext = UserDefaults.standard.bool(forKey: "autoStartNext")
        
        let dailyGoal = UserDefaults.standard.integer(forKey: "dailyFocusGoalMinutes")
        self.dailyFocusGoalMinutes = dailyGoal == 0 ? 120 : dailyGoal
        
        self.enableInAppAOD = UserDefaults.standard.object(forKey: "enableInAppAOD") == nil ? true : UserDefaults.standard.bool(forKey: "enableInAppAOD")
        self.selectedThemeID = UserDefaults.standard.string(forKey: "selectedThemeID") ?? "default"
        self.currentTaskName = UserDefaults.standard.string(forKey: "currentTaskName") ?? "Focus Time"
        self.currentTaskTopic = UserDefaults.standard.string(forKey: "currentTaskTopic") ?? "General"
    }
}
