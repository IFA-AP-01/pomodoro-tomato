import Testing
import Foundation
@testable import Pomodoro

struct SettingsServiceTests {

    @Test func testUserDefaultsSynchronization() {
        let settings = SettingsService()
        let originalFocusTime = settings.focusTimeMinutes
        let newFocusTime = originalFocusTime + 5
        
        settings.focusTimeMinutes = newFocusTime
        
        let savedFocusTime = UserDefaults.standard.integer(forKey: "focusTimeMinutes")
        #expect(savedFocusTime == newFocusTime)
        
        // Restore
        settings.focusTimeMinutes = originalFocusTime
    }
    
    @Test func testThemeSynchronization() {
        let settings = SettingsService()
        let originalTheme = settings.selectedThemeID
        let newTheme = originalTheme == "default" ? "dark" : "default"
        
        settings.selectedThemeID = newTheme
        
        let savedTheme = UserDefaults.standard.string(forKey: "selectedThemeID")
        #expect(savedTheme == newTheme)
        
        // Restore
        settings.selectedThemeID = originalTheme
    }

    @Test func testCurrentThemeReflectsSelectedThemeID() {
        let settings = SettingsService()
        
        settings.selectedThemeID = "default"
        #expect(settings.currentTheme.id == "default")
        
        settings.selectedThemeID = "dark"
        #expect(settings.currentTheme.id == "dark")
        
        // Restore
        settings.selectedThemeID = "default"
    }
}
