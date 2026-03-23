import SwiftUI

struct PomodoroTheme: Identifiable, Equatable {
    let id: String
    let name: String
    let background: Color
    let text: Color
    let accent: Color
    let surface: Color // Used for cards
    let cardText: Color // Primary text on surface
    let cardSecondaryText: Color // Secondary text on surface
    let cardElementBackground: Color // Background for elements inside cards
    let timerBackground: Color
    let statusText: Color // For the "Focus" status in timer
    let tabActive: Color
    let tabInactive: Color
    
    static let defaultTheme = PomodoroTheme(
        id: "default",
        name: "Default White",
        background: Color(white: 0.98),
        text: .black,
        accent: Color(red: 0.98, green: 0.82, blue: 0.22),
        surface: Color(white: 0.92),
        cardText: .black,
        cardSecondaryText: Color(white: 0.4),
        cardElementBackground: .white,
        timerBackground: Color(white: 0.85),
        statusText: .black,
        tabActive: .black,
        tabInactive: Color(white: 0.6)
    )
    
    static let darkTheme = PomodoroTheme(
        id: "dark",
        name: "Night Black",
        background: .black,
        text: .white,
        accent: Color(red: 0.98, green: 0.82, blue: 0.22),
        surface: Color(white: 0.12),
        cardText: .white,
        cardSecondaryText: Color(white: 0.5),
        cardElementBackground: Color(white: 0.08),
        timerBackground: Color(white: 0.2),
        statusText: .white,
        tabActive: .white,
        tabInactive: Color(white: 0.4)
    )
    
    static let allThemes: [PomodoroTheme] = [.defaultTheme, .darkTheme]
    
    static func from(id: String) -> PomodoroTheme {
        allThemes.first(where: { $0.id == id }) ?? .defaultTheme
    }
    
    static func generate(mode: String, dynamicColor: Bool, colorScheme: Color, blackTheme: Bool) -> PomodoroTheme {
        @Environment(\.colorScheme) var systemColorScheme // Used to check system mode if mode is "system"
        // Since we are not in a view, we have to rely on UIKit trait collection for system color scheme
        let isSystemDark = UITraitCollection.current.userInterfaceStyle == .dark
        
        let isDark: Bool
        switch mode {
        case "dark": isDark = true
        case "light": isDark = false
        default: isDark = isSystemDark // "system"
        }
        
        let accent = dynamicColor ? colorScheme : Color(red: 0.98, green: 0.82, blue: 0.22)
        
        if isDark {
            return PomodoroTheme(
                id: mode,
                name: "Custom Dark",
                background: blackTheme ? .black : Color(white: 0.05),
                text: .white,
                accent: accent,
                surface: blackTheme ? Color(white: 0.1) : Color(white: 0.12),
                cardText: .white,
                cardSecondaryText: Color(white: 0.5),
                cardElementBackground: blackTheme ? Color(white: 0.15) : Color(white: 0.08),
                timerBackground: Color(white: 0.2),
                statusText: .white,
                tabActive: .white,
                tabInactive: Color(white: 0.4)
            )
        } else {
            return PomodoroTheme(
                id: mode,
                name: "Custom Light",
                background: Color(red: 0.98, green: 0.92, blue: 0.90), // Hint of warm background like in the image
                text: .black,
                accent: accent,
                surface: .white,
                cardText: .black,
                cardSecondaryText: Color(white: 0.4),
                cardElementBackground: Color(white: 0.96),
                timerBackground: Color(white: 0.85),
                statusText: .black,
                tabActive: .black,
                tabInactive: Color(white: 0.6)
            )
        }
    }
}
