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
    
    var themeMode: String {
        didSet { UserDefaults.standard.set(themeMode, forKey: "themeMode") }
    }
    
    var dynamicColor: Bool {
        didSet { UserDefaults.standard.set(dynamicColor, forKey: "dynamicColor") }
    }
    
    var colorScheme: String {
        didSet { UserDefaults.standard.set(colorScheme, forKey: "colorScheme") }
    }
    
    var blackTheme: Bool {
        didSet { UserDefaults.standard.set(blackTheme, forKey: "blackTheme") }
    }
    
    var currentTaskName: String {
        didSet { UserDefaults.standard.set(currentTaskName, forKey: "currentTaskName") }
    }
    
    var currentTaskTopic: String {
        didSet { UserDefaults.standard.set(currentTaskTopic, forKey: "currentTaskTopic") }
    }
    
    var currentTheme: PomodoroTheme {
        return PomodoroTheme.generate(
            mode: themeMode,
            dynamicColor: dynamicColor,
            colorScheme: colorSchemeStrungToColor(colorScheme),
            blackTheme: blackTheme
        )
    }
    
    private func colorSchemeStrungToColor(_ name: String) -> Color {
        // Return preset colors or a default
        switch name {
        case "pink": return Color.pink
        case "purple": return Color.purple
        case "blue": return Color.blue
        case "cyan": return Color.cyan
        case "mint": return Color.mint
        case "green": return Color.green
        case "yellow": return Color.yellow
        case "orange": return Color.orange
        case "red": return Color.red
        default: return Color(red: 0.98, green: 0.82, blue: 0.22) // Default Tomato Yellow
        }
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
        self.themeMode = UserDefaults.standard.object(forKey: "themeMode") as? String ?? "system"
        self.dynamicColor = UserDefaults.standard.bool(forKey: "dynamicColor")
        self.colorScheme = UserDefaults.standard.object(forKey: "colorScheme") as? String ?? "default"
        self.blackTheme = UserDefaults.standard.bool(forKey: "blackTheme")
        
        // Migrate old selectedThemeID to themeMode if present
        if let oldTheme = UserDefaults.standard.string(forKey: "selectedThemeID") {
            if oldTheme == "dark" {
                self.themeMode = "dark"
            } else if oldTheme == "default" {
                self.themeMode = "light"
            }
            UserDefaults.standard.removeObject(forKey: "selectedThemeID")
        }
        
        self.currentTaskName = UserDefaults.standard.string(forKey: "currentTaskName") ?? "Focus Time"
        self.currentTaskTopic = UserDefaults.standard.string(forKey: "currentTaskTopic") ?? "General"
    }
}
