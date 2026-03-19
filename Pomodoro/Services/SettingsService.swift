import SwiftUI

@Observable
class SettingsService {
    var focusTimeMinutes: Int {
        get { UserDefaults.standard.integer(forKey: "focusTimeMinutes") == 0 ? 25 : UserDefaults.standard.integer(forKey: "focusTimeMinutes") }
        set { UserDefaults.standard.set(newValue, forKey: "focusTimeMinutes") }
    }
    
    var shortBreakMinutes: Int {
        get { UserDefaults.standard.integer(forKey: "shortBreakMinutes") == 0 ? 5 : UserDefaults.standard.integer(forKey: "shortBreakMinutes") }
        set { UserDefaults.standard.set(newValue, forKey: "shortBreakMinutes") }
    }
    
    var longBreakMinutes: Int {
        get { UserDefaults.standard.integer(forKey: "longBreakMinutes") == 0 ? 15 : UserDefaults.standard.integer(forKey: "longBreakMinutes") }
        set { UserDefaults.standard.set(newValue, forKey: "longBreakMinutes") }
    }
    
    var cyclesBeforeLongBreak: Int {
        get { UserDefaults.standard.integer(forKey: "cyclesBeforeLongBreak") == 0 ? 4 : UserDefaults.standard.integer(forKey: "cyclesBeforeLongBreak") }
        set { UserDefaults.standard.set(newValue, forKey: "cyclesBeforeLongBreak") }
    }
    
    var autoStartNext: Bool {
        get { UserDefaults.standard.bool(forKey: "autoStartNext") }
        set { UserDefaults.standard.set(newValue, forKey: "autoStartNext") }
    }
    
    var forceDarkMode: Bool {
        get { UserDefaults.standard.bool(forKey: "forceDarkMode") }
        set { UserDefaults.standard.set(newValue, forKey: "forceDarkMode") }
    }
    
    var dailyFocusGoalMinutes: Int {
        get { UserDefaults.standard.integer(forKey: "dailyFocusGoalMinutes") == 0 ? 120 : UserDefaults.standard.integer(forKey: "dailyFocusGoalMinutes") }
        set { UserDefaults.standard.set(newValue, forKey: "dailyFocusGoalMinutes") }
    }
    
    var enableInAppAOD: Bool {
        get { UserDefaults.standard.object(forKey: "enableInAppAOD") == nil ? true : UserDefaults.standard.bool(forKey: "enableInAppAOD") }
        set { UserDefaults.standard.set(newValue, forKey: "enableInAppAOD") }
    }
}
