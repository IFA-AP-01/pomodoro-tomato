import SwiftUI

enum TabSelection {
    case stats
    case timer
    case settings
}

struct ContentView: View {
    @Environment(SettingsService.self) private var settingsService
    @State private var selectedTab: TabSelection = .timer
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            Group {
                switch selectedTab {
                case .stats:
                    StatsView()
                case .timer:
                    TimerView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            HStack(spacing: 15) {
                TabBarButton(
                    icon: "chart.bar.xaxis",
                    title: "Dashboard",
                    isSelected: selectedTab == .stats
                ) {
                    selectedTab = .stats
                }
                
                TabBarButton(
                    icon: "timer",
                    title: "Timer",
                    isSelected: selectedTab == .timer
                ) {
                    selectedTab = .timer
                }
                
                TabBarButton(
                    icon: "gearshape.fill",
                    title: "Settings",
                    isSelected: selectedTab == .settings
                ) {
                    selectedTab = .settings
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(settingsService.currentTheme.surface)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .padding(.bottom, 30) // Lifted slightly from bottom edge
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct TabBarButton: View {
    @Environment(SettingsService.self) private var settingsService
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private var theme: PomodoroTheme {
        settingsService.currentTheme
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                
                if isSelected {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, isSelected ? 20 : 12)
            .background(isSelected ? theme.background : Color.clear)
            .foregroundColor(isSelected ? theme.tabActive : theme.tabInactive)
            .clipShape(Capsule())
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    ContentView()
        .environment(SettingsService())
}
