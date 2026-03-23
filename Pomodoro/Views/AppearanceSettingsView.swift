import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(SettingsService.self) private var settings
    @Environment(\.dismiss) private var dismiss
    
    let colorOptions: [(name: String, color: Color)] = [
        ("pink", Color(red: 1.0, green: 0.85, blue: 0.85)),
        ("lightPink", Color(red: 1.0, green: 0.9, blue: 0.92)),
        ("purple", Color(red: 0.95, green: 0.85, blue: 1.0)),
        ("blue", Color(red: 0.85, green: 0.9, blue: 1.0)),
        ("cyan", Color(red: 0.8, green: 0.95, blue: 1.0)),
        ("mint", Color(red: 0.8, green: 0.95, blue: 0.9))
    ]
    
    var body: some View {
        @Bindable var bindableSettings = settings
        let theme = settings.currentTheme
        
        ZStack {
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(theme.text)
                            .padding(14)
                            .background(theme.surface)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                            .padding(.leading, 20)
                    }
                    Spacer()
                }
                .padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Appearance")
                        .font(.system(size: 38, weight: .heavy))
                        .foregroundColor(theme.text)
                    Text("Settings")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(theme.cardSecondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 25)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Theme Switcher Card
                        cardContainer(theme: theme) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 12) {
                                    Image(systemName: "sun.max")
                                        .font(.system(size: 20))
                                        .foregroundColor(theme.text)
                                    Text("Theme")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(theme.text)
                                }
                                
                                HStack(spacing: 12) {
                                    themeOptionButton(title: "System", mode: "system", theme: theme)
                                    themeOptionButton(title: "Light", mode: "light", theme: theme)
                                    themeOptionButton(title: "Dark", mode: "dark", theme: theme)
                                }
                            }
                            .padding(.vertical, 20)
                        }
                        
                        // Customize Button
                        HStack(spacing: 12) {
                            Rectangle().fill(theme.cardSecondaryText.opacity(0.3)).frame(height: 2)
                            Button(action: {}) {
                                Text("Customize further with Tomato+")
                                    .font(.system(size: 14, weight: .bold))
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                    .background(theme.accent)
                                    .clipShape(Capsule())
                            }
                            .layoutPriority(1)
                            Rectangle().fill(theme.cardSecondaryText.opacity(0.3)).frame(height: 2)
                        }
                        .padding(.horizontal, 20)
                        
                        // Customization Card
                        cardContainer(theme: theme) {
                            VStack(spacing: 0) {
                                Toggle(isOn: $bindableSettings.dynamicColor) {
                                    HStack(alignment: .center, spacing: 16) {
                                        Image(systemName: "drop.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(theme.text)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Dynamic color")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(theme.text)
                                            Text("Adapt theme colors from your wallpaper")
                                                .font(.system(size: 14))
                                                .foregroundColor(theme.cardSecondaryText)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                                .tint(theme.accent)
                                .padding(.vertical, 20)
                                
                                Divider().background(theme.cardSecondaryText.opacity(0.2))
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(alignment: .center, spacing: 16) {
                                        Image(systemName: "paintpalette.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(theme.text)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Color scheme")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(theme.text)
                                            Text(settings.dynamicColor ? "Dynamic" : "Custom")
                                                .font(.system(size: 14))
                                                .foregroundColor(theme.cardSecondaryText)
                                        }
                                    }
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(colorOptions, id: \.name) { option in
                                                Circle()
                                                    .fill(option.color)
                                                    .frame(width: 56, height: 56)
                                                    .padding(2)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(theme.cardSecondaryText.opacity(0.5), lineWidth: settings.colorScheme == option.name ? 2 : 0)
                                                    )
                                                    .onTapGesture {
                                                        settings.colorScheme = option.name
                                                    }
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                    }
                                }
                                .padding(.vertical, 20)
                                
                                Divider().background(theme.cardSecondaryText.opacity(0.2))
                                
                                Toggle(isOn: $bindableSettings.blackTheme) {
                                    HStack(alignment: .center, spacing: 16) {
                                        Image(systemName: "circle.lefthalf.filled")
                                            .font(.system(size: 20))
                                            .foregroundColor(theme.text)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Black theme")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(theme.text)
                                            Text("Use a pure black dark theme")
                                                .font(.system(size: 14))
                                                .foregroundColor(theme.cardSecondaryText)
                                        }
                                    }
                                }
                                .tint(theme.accent)
                                .padding(.vertical, 20)
                            }
                        }
                        
                        Color.clear.frame(height: 120) // Bottom padding for tab bar
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func cardContainer<Content: View>(theme: PomodoroTheme, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 20)
            .background(theme.surface)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(theme.id == "light" || theme.id == "system" ? 0.03 : 0), radius: 10, y: 5)
    }
    
    private func themeOptionButton(title: String, mode: String, theme: PomodoroTheme) -> some View {
        let isSelected = settings.themeMode == mode
        return Button(action: { settings.themeMode = mode }) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(isSelected ? .white : theme.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isSelected ? theme.accent : theme.cardElementBackground)
                .clipShape(Capsule())
        }
    }
}
